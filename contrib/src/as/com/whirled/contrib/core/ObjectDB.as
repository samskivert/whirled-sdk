package com.whirled.contrib.core {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.util.HashMap;
import com.whirled.contrib.core.components.SceneComponent;

import flash.display.DisplayObjectContainer;

public class ObjectDB
{
    public function ObjectDB ()
    {
    }

    /**
     * Adds an AppObject to the database. The AppObject must not be owned by another database.
     * If displayParent is not null, obj's attached DisplayObject will be added as a child
     * of displayParent.
     */
    public function addObject (obj :AppObject, displayParent :DisplayObjectContainer = null) :AppObjectRef
    {
        if (null == obj || null != obj._ref) {
            throw new ArgumentError("obj must be non-null, and must never have belonged to another ObjectDB");
        }
        
        // create a new AppObjectRef
        var ref :AppObjectRef = new AppObjectRef();
        ref._obj = obj;
        
        // add the ref to the list
        var oldListHead :AppObjectRef = _listHead;
        _listHead = ref;
        
        if (null != oldListHead) {
            ref._next = oldListHead;
            oldListHead._prev = ref;
        }
        
        // initialize object
        obj._parentDB = this;
        obj._ref = ref;

        // does the object have a name?
        if (null != obj.objectName) {
            if (_namedObjects.get(obj.objectName) != null) {
                throw new Error("can't add two objects with the same name to the same ObjectDB");
            }
            
            _namedObjects.put(obj.objectName, obj);
        }

        // is the object in any groups?
        var groupNames :Array = obj.objectGroups;
        if (null != groupNames) {
            for each (var groupName :* in groupNames) {
                var groupArray :Array = (_groupedObjects.get(groupName) as Array);
                if (null == groupArray) {
                    groupArray = new Array();
                    _groupedObjects.put(groupName, groupArray);
                }

                groupArray.push(ref);
            }
        }

        // should the object be attached to a display parent?
        // (this is purely a convenience - the client is free to
        // do the attaching themselves)
        if (null != displayParent) {
            var sc :SceneComponent = (obj as SceneComponent);
            if (null == sc || null == sc.displayObject) {
                throw new Error("only objects implementing SceneComponent can be attached to a display parent");
            }
            
            displayParent.addChild(sc.displayObject);
        }

        obj.addedToDBInternal();

        ++_objectCount;

        return ref;
    }
    
    /** Removes an AppObject from the mode. */
    public function destroyObjectNamed (name :String) :void
    {
        var obj :AppObject = this.getObjectNamed(name);
        if (null != obj) {
            this.destroyObject(obj.ref);
        }
    }
    
    /** Removes an AppObject from the mode. */
    public function destroyObject (ref :AppObjectRef) :void
    {
        if (null == ref) {
            return;
        }
        
        var obj :AppObject = ref.object;
        
        if (null == obj) {
            return;
        }
        
        // the ref no longer points to the object
        ref._obj = null;
        
        // if the object is attached to a DisplayObject, and if that
        // DisplayObject is in a display list, remove it from the display list
        // so that it will no longer be drawn to the screen
        var sc :SceneComponent = (obj as SceneComponent);
        if (null != sc && null != sc.displayObject && null != sc.displayObject.parent) {
            sc.displayObject.parent.removeChild(sc.displayObject);
        }

        // does the object have a name?
        if (null != obj.objectName) {
            Assert.isTrue(_namedObjects.get(obj.objectName) == obj);
            _namedObjects.put(obj.objectName, null);
        }

        obj.destroyedInternal();
        
        if (null == _objectsPendingDestroy) {
            _objectsPendingDestroy = new Array();
        }
        
        // the ref will be unlinked from the objects list
        // at the end of the update()
        _objectsPendingDestroy.push(obj);

        --_objectCount;
    }

    protected function finalizeObjectDestruction (obj :AppObject) :void
    {
        Assert.isTrue(null != obj._ref && null == obj._ref._obj);
        
        // unlink the object ref
        var ref :AppObjectRef = obj._ref;
        
        var prev :AppObjectRef = ref._prev;
        var next :AppObjectRef = ref._next;
        
        if (null != prev) {
            prev._next = next;
        } else {
            // if prev is null, ref was the head of the list
            Assert.isTrue(ref == _listHead);
            _listHead = next;
        }
        
        if (null != next) {
            next._prev = prev;
        }

        // is the object in any groups?
        // (we remove the object from its groups here, rather than in
        // destroyObject(), because client code might be iterating an
        // object group Array when destroyObject is called)
        var groupNames :Array = obj.objectGroups;
        if (null != groupNames) {
            for each (var groupName :* in groupNames) {
                var groupArray :Array = (_groupedObjects.get(groupName) as Array);
                Assert.isTrue(null != groupArray);
                var wasInArray :Boolean = ArrayUtil.removeFirst(groupArray, ref);
                Assert.isTrue(wasInArray);
            }
        }
        
        obj._parentDB = null;
    }

    /** Returns the object in this mode with the given name, or null if no such object exists. */
    public function getObjectNamed (name :String) :AppObject
    {
        return (_namedObjects.get(name) as AppObject);
    }

    /** 
     * Returns an Array containing the object refs of all the objects in the given group. 
     * This Array must not be modified by client code.
     * 
     * Note: because of the method that object destruction is implemented with,
     * the returned Array may contain null object refs.
     */
    public function getObjectRefsInGroup (groupName :String) :Array
    {
        var refs :Array = (_groupedObjects.get(groupName) as Array);

        return (null != refs ? refs : new Array());
    }
    
    /**
     * Returns an Array containing the AppObjects in the given group.
     * The returned Array is instantiated by the function, and so can be
     * safely modified by client code.
     * 
     * This function is not as performant as getObjectRefsInGroup().
     */
    public function getObjectsInGroup (groupName :String) :Array
    {
        var refs :Array = this.getObjectRefsInGroup(groupName);
        
        // Array.map would be appropriate here, except that the resultant
        // Array might contain fewer entries than the source.
        
        var objs :Array = new Array();
        for each (var ref :AppObjectRef in refs) {
            if (!ref.isNull) {
                objs.push(ref.object);
            }
        }
        
        return objs;
    }

    /** Called once per update tick. Updates all objects in the mode. */
    public function update (dt :Number) :void
    {
        var obj :AppObject;
        
        // update all objects
        
        var ref :AppObjectRef = _listHead;
        while (null != ref) {
            if (!ref.isNull) {
                ref.object.updateInternal(dt);
            }
            
            ref = ref._next;
        }
        
        // clean out all objects that were destroyed during the update loop
        
        if (null != _objectsPendingDestroy) {
            for each (obj in _objectsPendingDestroy) {
                this.finalizeObjectDestruction(obj);
            }
            
            _objectsPendingDestroy = null;
        }
    }

    /** Sends a message to every object in the database. */
    public function broadcastMessage (msg :ObjectMessage) :void
    {
        var ref :AppObjectRef = _listHead;
        while (null != ref) {
            if (!ref.isNull) {
                ref.object.receiveMessageInternal(msg);
            }
            
            ref = ref._next;
        }
    }

    /** Sends a message to a specific object. */
    public function sendMessageTo (msg :ObjectMessage, targetRef :AppObjectRef) :void
    {
        if (!targetRef.isNull) {
            targetRef.object.receiveMessageInternal(msg);
        }
    }

    /** Sends a message to the object with the given name. */
    public function sendMessageToNamedObject (msg :ObjectMessage, objectName :String) :void
    {
        var target :AppObject = this.getObjectNamed(objectName);
        if (null != target) {
            target.receiveMessageInternal(msg);
        }
    }

    /** Sends a message to each object in the given group. */
    public function sendMessageToGroup (msg :ObjectMessage, groupName :String) :void
    {
        var refs :Array = this.getObjectRefsInGroup(groupName);
        for each (var ref :AppObjectRef in refs) {
            this.sendMessageTo(msg, ref);
        }
    }

    public function get objectCount () :uint
    {
        return _objectCount;
    }

    protected var _listHead :AppObjectRef;
    protected var _objectCount :uint;
    
    /** An array of AppObjects */
    protected var _objectsPendingDestroy :Array;

    /** stores a mapping from String to Object */
    protected var _namedObjects :HashMap = new HashMap();

    /** stores a mapping from String to Array */
    protected var _groupedObjects :HashMap = new HashMap();
}

}
