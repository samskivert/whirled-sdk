//
// $Id$

package com.whirled.contrib.platformer.editor {

import mx.collections.HierarchicalData;
import mx.containers.VBox;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.Button;
import mx.events.ListEvent;
import mx.events.FlexEvent;

import com.threerings.util.ClassUtil;

import com.whirled.contrib.platformer.board.Board;

import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.Dynamic;

public class DynamicTree extends BaseTree
{
    public function DynamicTree (b :Board, dynamics :XML)
    {
        super(b);
        _dxml = dynamics;
    }

    public function addDynamic (d :Dynamic, group :String) :void
    {
        var xml :XML = <dyn/>;
        xml.@label = ClassUtil.tinyClassName(d);
        xml.@name = d.id;
        if (addXML(xml, "root." + group) != null) {
            var idx :int = Board.GROUP_NAMES.indexOf(group);
            _board.addDynamicIns(d, idx);
            _adg.selectedItem = xml;
            handleChange(null);
        }
    }

    protected override function addButtons (box :VBox) :void
    {
        super.addButtons(box);
        box.addChild(_settingsBox = new VBox());
    }

    protected override function getItemName (tree :String) :String
    {
        return "dyn";
    }

    protected override function getColumn () :AdvancedDataGridColumn
    {
        var column :AdvancedDataGridColumn = new AdvancedDataGridColumn("Dynamic");
        column.dataField = "@label";
        return column;
    }

    protected override function createHD () :HierarchicalData
    {
        return new HierarchicalData(buildDynamicTree());
    }

    protected function buildDynamicTree () :XML
    {
        var root :XML = <node>group</node>;
        root.@label = "root";
        root.@name = "root";
        for (var ii :int = 0; ii < Board.GROUP_NAMES.length; ii++) {
            var group :XML = <node>group</node>;
            group.@label = Board.GROUP_NAMES[ii];
            group.@name = Board.GROUP_NAMES[ii];
            root.appendChild(group);
            for each (var node :XML in _board.getDynamicsXML(ii).children()) {
                var xml :XML = <dyn/>;
                xml.@label = node.@type;
                xml.@name = node.@id;
                group.appendChild(xml);
            }
        }
        return root;
    }

    protected override function handleChange (event :ListEvent) :void
    {
        super.handleChange(event);
        updateDetails();
    }

    protected function updateDetails () :void
    {
        _settingsBox.removeAllChildren();
        _details = null;
        if (_group == _adg.selectedItem || _adg.selectedItem == null) {
            _dynamic = null;
        } else {
            _dynamic = _board.getItem((_adg.selectedItem as XML).@name, _tree) as Dynamic;
        }
        if (_dynamic == null) {
            return;
        }
        var def :XML;
        var group :String = _group.@name;
        def = _dxml.elements(group)[0].dynamicdef.(@type == ClassUtil.tinyClassName(_dynamic))[0];
        if (def == null ||
                (def.elements("var").length() == 0 && def.elements("const").length() == 0)) {
            return;
        }
        _details = new Array();
        for each (var varxml :XML in def.elements("var")) {
            var detail :DynamicDetail = new DynamicDetail(varxml, _dynamic);
            _settingsBox.addChild(detail.createBox());
            _details.push(detail);
        }
        for each (varxml in def.elements("const")) {
            (_dynamic as Object)[varxml.@id.toString()] = varxml.@value;
        }
        var button :Button = new Button();
        button.label = "Update";
        button.addEventListener(FlexEvent.BUTTON_DOWN, updateDynamic);
        _settingsBox.addChild(button);
    }

    protected function updateDynamic (event :FlexEvent) :void
    {
        for each (var detail :DynamicDetail in _details) {
            detail.updateDynamic(_dynamic);
        }
        var group :String = _group.@name;
        _board.updateDynamicIns(_dynamic, Board.GROUP_NAMES.indexOf(group));
    }

    protected var _dxml :XML;
    protected var _settingsBox :VBox;
    protected var _details :Array;
    protected var _dynamic :Dynamic;
}
}