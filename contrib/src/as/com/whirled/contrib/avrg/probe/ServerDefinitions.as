// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.avrg.probe {

import com.threerings.util.ClassUtil;
import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.MobSubControlServer;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.PropertySubControl;

/**
 * Encapsulates the function definitions available to an AVRG server agent.
 */
public class ServerDefinitions
{
    // TODO: tweak these to be specific to the server event set

    /** Events that apply to a GameSubControlServer. */
    public static const GAME_EVENTS :Array = Definitions.GAME_EVENTS;

    /** Events that apply to a RoomSubControlServer. */
    public static const ROOM_EVENTS :Array = Definitions.ROOM_EVENTS;

    /** Events that apply to a property space (.props member). */
    public static const NET_EVENTS :Array = Definitions.NET_EVENTS;

    /** Events that apply to a PlayerSubControlServer. */
    public static const PLAYER_EVENTS :Array = Definitions.PLAYER_EVENTS;

    /**
     * Creates a new set of server definitions based on a given top-level game control.
     */
    public function ServerDefinitions (ctrl :AVRServerGameControl)
    {
        _ctrl = ctrl;

        _funcs.room = createRoomFuncs();
        _funcs.misc = createMiscFuncs();
        _funcs.game = createGameFuncs();
        _funcs.player = createPlayerFuncs();
        _funcs.mob = createMobFuncs();
    }

    /**
     * Lookup a function by scoped name. This is the category followed by a dot followed by the
     * function name. For example, "room.getPlayerIds".
     */
    public function findByName (name :String) :FunctionSpec
    {
        var dot :int = name.indexOf(".");
        var scope :String = name.substr(0, dot);
        name = name.substr(dot + 1);
        var fnArray :Array = _funcs[scope];
        if (fnArray == null) {
            return null;
        }
        for each (var spec :FunctionSpec in fnArray) {
            if (spec.name == name) {
                return spec;
            }
        }
        return null;
    }

    /**
     * Print out the RPC versions of all server functions suitable for pasting into client 
     * definitions.
     */
    public function dump () :void
    {
        for (var scope :String in _funcs) {
            trace("    // AUTO GENERATED from ServerDefinitions");
            trace("    protected function createServer" + scope.substr(0, 1).toUpperCase() + 
                  scope.substr(1) + "Funcs () :Array");
            trace("    {");
            trace("        return [");
            for each (var fnSpec :FunctionSpec in _funcs[scope]) {
                var proxy :String = "proxy(\"" + scope + "\", \"" + fnSpec.name + "\")";
                var specStart :String = "            new FunctionSpec(\"" + fnSpec.name + "\"";
                specStart += ", " + proxy;
                if (fnSpec.parameters.length == 0) {
                    trace(specStart + "),");
                } else {
                    specStart += ", ["
                    trace(specStart);
                
                    for (var ii :int = 0; ii < fnSpec.parameters.length; ++ii) {
                        var param :Parameter = fnSpec.parameters[ii];
                        var paramStr :String = ClassUtil.getClassName(param);
                        paramStr += "(\"" + param.name + "\"";
                        if (ClassUtil.getClass(param) != ObjectParameter) {
                            paramStr += ", " + ClassUtil.getClassName(param.type);
                        }
                        if (param.optional || param.nullable) {
                            var flags :Array = [];
                            if (param.optional) {
                                flags.push("Parameter.OPTIONAL");
                            }
                            if (param.nullable) {
                                flags.push("Parameter.NULLABLE");
                            }
                            var flagStr :String = flags[0];
                            for (var jj :int = 1; jj < flags.length; ++jj) {
                                flagStr += "|" + flags[jj];
                            }
                            paramStr += ", " + flagStr;
                        }
                        paramStr += ")";
                        if (ii == fnSpec.parameters.length - 1) {
                            paramStr += "]),";
                        } else {
                            paramStr += ",";
                        }
                        trace("                new " + paramStr);
                    }
                }
            }
            trace("        ];");
            trace("    }");
            trace("");
        }
    }

    protected function createGameFuncs () :Array
    {
        var funcs :Array = [
            new FunctionSpec("getPlayerIds", _ctrl.game.getPlayerIds),
            new FunctionSpec("sendMessage", _ctrl.game.sendMessage, [
                new Parameter("name", String),
                new ObjectParameter("value")])];
        var props :Array = [];

        pushPropsFuncs(props, "game", function (id :int) :PropertySubControl {
            return _ctrl.game.props;
        });

        // stub out those id parameters
        function prependZero (func :Function) :Function {
            function stubby (...args) :* {
                args.unshift(0);
                return func.apply(null, args);
            }
            return stubby;
        }

        for (var ii :int = 0; ii < props.length; ++ii) {
            var fs :FunctionSpec = props[ii];
            var params :Array = fs.parameters;
            params.shift();
            props[ii] = new FunctionSpec(fs.name, prependZero(fs.func), params);
        }

        funcs.push.apply(funcs, props);
        return funcs;
    }

    protected function createRoomFuncs () :Array
    {
        function getInstance (id :int) :RoomSubControlServer {
            var room :RoomSubControlServer = _ctrl.getRoom(id);
            return room;
        }

        function getRoomId (room :RoomSubControlServer) :Function {
            return room.getRoomId;
        }

        function getPlayerIds (room :RoomSubControlServer) :Function {
            return room.getPlayerIds;
        }

        function isPlayerHere (room :RoomSubControlServer) :Function {
            return room.isPlayerHere;
        }

        function getAvatarInfo (room :RoomSubControlServer) :Function {
            return room.getAvatarInfo;
        }

        function getRoomBounds (room :RoomSubControlServer) :Function {
            return room.getRoomBounds;
        }

        function spawnMob (room :RoomSubControlServer) :Function {
            return room.spawnMob;
        }

        function despawnMob (room :RoomSubControlServer) :Function {
            return room.despawnMob;
        }

        function getSpawnedMobs (room :RoomSubControlServer) :Function {
            return room.getSpawnedMobs;
        }

        function sendMessage (room :RoomSubControlServer) :Function {
            return room.sendMessage;
        }

        var idParam :Parameter = new Parameter("roomId", int);

        var funcs :Array = [
            new FunctionSpec("getRoomId", proxy(getInstance, getRoomId), [idParam]),
            new FunctionSpec("getPlayerIds", proxy(getInstance, getPlayerIds), [idParam]),
            new FunctionSpec("isPlayerHere", proxy(getInstance, isPlayerHere), [
                idParam, new Parameter("id", int)]),
            new FunctionSpec("getAvatarInfo", proxy(getInstance, getAvatarInfo), [
                idParam, new Parameter("playerId", int)]),
            new FunctionSpec("getRoomBounds", proxy(getInstance, getRoomBounds), [idParam]),
            new FunctionSpec("spawnMob", proxy(getInstance, spawnMob), [
                idParam, new Parameter("id", String), new Parameter("name", String),
                new Parameter("x", Number), new Parameter("y", Number), 
                new Parameter("z", Number)]),
            new FunctionSpec("despawnMob", proxy(getInstance, despawnMob), [
                idParam, new Parameter("id", String)]),
            new FunctionSpec("getSpawnedMobs", proxy(getInstance, getSpawnedMobs), [idParam]),
            new FunctionSpec("sendMessage", proxy(getInstance, sendMessage), [
                idParam, new Parameter("name", String), new ObjectParameter("value")]),
        ];

        pushPropsFuncs(funcs, "room", function (id :int) :PropertySubControl {
            return getInstance(id).props;
        });

        return funcs;
    }

    protected function createPlayerFuncs () :Array
    {
        var idParam :Parameter = new Parameter("playerId", int);

        function getInstance (id :int) :PlayerSubControlServer {
            var player :PlayerSubControlServer = _ctrl.getPlayer(id);
            return player;
        }

        function getPlayerId (props :PlayerSubControlServer) :Function {
            return props.getPlayerId;
        }

        function getRoomId (props :PlayerSubControlServer) :Function {
            return props.getRoomId;
        }

        function holdsTrophy (props :PlayerSubControlServer) :Function {
            return props.holdsTrophy;
        }

        function awardTrophy (props :PlayerSubControlServer) :Function {
            return props.awardTrophy;
        }

        function awardPrize (props :PlayerSubControlServer) :Function {
            return props.awardPrize;
        }

        function getPlayerItemPacks (props :PlayerSubControlServer) :Function {
            return props.getPlayerItemPacks;
        }

        function getPlayerLevelPacks (props :PlayerSubControlServer) :Function {
            return props.getPlayerLevelPacks;
        }

        function deactivateGame (props :PlayerSubControlServer) :Function {
            return props.deactivateGame;
        }

        function completeTask (props :PlayerSubControlServer) :Function {
            return props.completeTask;
        }

        function playAvatarAction (props :PlayerSubControlServer) :Function {
            return props.playAvatarAction;
        }

        function setAvatarState (props :PlayerSubControlServer) :Function {
            return props.setAvatarState;
        }

        function setAvatarMoveSpeed (props :PlayerSubControlServer) :Function {
            return props.setAvatarMoveSpeed;
        }

        function setAvatarLocation (props :PlayerSubControlServer) :Function {
            return props.setAvatarLocation;
        }

        function setAvatarOrientation (props :PlayerSubControlServer) :Function {
            return props.setAvatarOrientation;
        }

        function sendMessage (props :PlayerSubControlServer) :Function {
            return props.sendMessage;
        }

        var funcs :Array = [
            new FunctionSpec("getPlayerId", proxy(getInstance, getPlayerId), [idParam]),
            new FunctionSpec("getRoomId", proxy(getInstance, getRoomId), [idParam]),
            new FunctionSpec("holdsTrophy", proxy(getInstance, holdsTrophy),
                             [idParam, new Parameter("ident", String)]),
            new FunctionSpec("awardTrophy", proxy(getInstance, awardTrophy),
                             [idParam, new Parameter("ident", String)]),
            new FunctionSpec("awardPrize", proxy(getInstance, awardPrize),
                             [idParam, new Parameter("ident", String)]),
            new FunctionSpec("getPlayerItemPacks", proxy(getInstance, getPlayerItemPacks),
                             [idParam]),
            new FunctionSpec("getPlayerLevelPacks", proxy(getInstance, getPlayerLevelPacks),
                             [idParam]),
            new FunctionSpec("deactivateGame", proxy(getInstance, deactivateGame), [idParam]),
            new FunctionSpec("completeTask", proxy(getInstance, completeTask), [idParam,
                new Parameter("taskId", String), new Parameter("payout", Number)]),
            new FunctionSpec("playAvatarAction", proxy(getInstance, playAvatarAction), [idParam,
                new Parameter("action", String)]),
            new FunctionSpec("setAvatarState", proxy(getInstance, setAvatarState), [idParam,
                new Parameter("state", String)]),
            new FunctionSpec("setAvatarMoveSpeed", proxy(getInstance, setAvatarMoveSpeed), [
                idParam, new Parameter("pixelsPerSecond", Number)]),
            new FunctionSpec("setAvatarLocation", proxy(getInstance, setAvatarLocation), [idParam,
                new Parameter("x", Number), new Parameter("y", Number), new Parameter("z", Number),
                new Parameter("orient", Number)]),
            new FunctionSpec("setAvatarOrientation", proxy(getInstance, setAvatarOrientation), [
                idParam, new Parameter("orient", Number)]),
            new FunctionSpec("sendMessage", proxy(getInstance, sendMessage), [idParam,
                new Parameter("name", String), new ObjectParameter("value")]),
        ];

        pushPropsFuncs(funcs, "player", function (id :int) :PropertySubControl {
            return getInstance(id).props;
        });

        return funcs;
    }

    protected function createMobFuncs () :Array
    {
        var roomIdParam :Parameter = new Parameter("roomId", int);
        var mobIdParam :Parameter = new Parameter("mobId", String);

        function getInstance (roomId :int, mobId :String) :MobSubControlServer {
            var mob :MobSubControlServer = _ctrl.getRoom(roomId).getMobSubControl(mobId);
            return mob;
        }

        function moveTo (roomId :int, mobId :String, ...args) :* {
            return _ctrl.getRoom(roomId).getMobSubControl(mobId).moveTo.apply(null, args);
        }

        var funcs :Array = [
            new FunctionSpec("moveTo", moveTo, [roomIdParam, mobIdParam, new Parameter("x", Number),
                new Parameter("y", Number), new Parameter("z", Number)]),
        ];

        return funcs;
    }

    protected function createMiscFuncs () :Array
    {
        return [
            new FunctionSpec("dump", dump, [])
        ];
    }

    protected function pushPropsFuncs (
        funcs :Array, targetName :String, instanceGetter :Function) :void
    {
        function get (props :PropertyGetSubControl) :Function {
            return props.get;
        }
           
        function getPropertyNames (props :PropertyGetSubControl) :Function {
            return props.getPropertyNames;
        }

        function set (props: PropertySubControl) :Function {
            return props.set;
        }

        function setAt (props: PropertySubControl) :Function {
            return props.setAt;
        }

        function setIn (props: PropertySubControl) :Function {
            return props.setIn;
        }

        var idParam :Parameter = new Parameter(targetName + "Id", int);

        funcs.push(
            new FunctionSpec("props.get", proxy(instanceGetter, get), [
                idParam,
                new Parameter("propName", String)]),
            new FunctionSpec("props.getPropertyNames", proxy(instanceGetter, getPropertyNames), [
                idParam,
                new Parameter("prefix", String, Parameter.OPTIONAL)]),
            new FunctionSpec("props.set", proxy(instanceGetter, set), [
                idParam,
                new Parameter("propName", String),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setAt", proxy(instanceGetter, setAt), [
                idParam,
                new Parameter("propName", String),
                new Parameter("index", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setIn", proxy(instanceGetter, setIn), [
                idParam,
                new Parameter("propName", String),
                new Parameter("key", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]));
    }

    protected function proxy (instanceGetter :Function, functionGetter :Function) :Function
    {
        function thunk (targetId :int, ...args) :Object {
            var subCtrl :AbstractSubControl = instanceGetter(targetId);
            var func :Function = functionGetter(subCtrl);
            return func.apply(subCtrl, args);
        }

        return thunk;
    }

    protected var _ctrl :AVRServerGameControl;
    protected var _funcs :Object = {};
}

}