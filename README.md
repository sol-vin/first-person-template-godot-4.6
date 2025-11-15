This template is for "sol-vin" style first person games. 

Contains dialogic, func_godot, and a goldsrc character controller.

Contains base material assets, a color pallette and accompanying 3d materials for those colors. Contains `PolygonMesh` object which colors meshes to be used in the outline shader. Also has a basic water shader and grass shader. Basic WorldEnvironment 

Auto-loads setup in project for helpers, threaded level loading, and material database.

Basic entities for Trenchbroom setup.
  - Worldspawn (collider, mesh)
  - Illusion (mesh)
  - Geo (collision)
  - Reference Brush (mesh but not visible)
  - Reference Point (mesh but not visible)

Basic nodes for working with Trenchbroom
  - `Aligner` - Aligns nodes with a target named node. Usually used to align a godot object/scene with a ReferenceBruch
  - `Areas` - Holds the loaded levels, and deals with loading and unloading them.
  - `ClickAction` - Allows an object to be clicked
  - `Crosshair` - Contains stuff for fading in and out the player crosshair
  - `Helpers` - Contains global helper functions
  - `Level` - Holds maps, allows for one click rebuilding of all children maps
  - `Map` - A .map file imported into Godot.
  - `RebuildHandler` - When parent `rebuild()` is called, call this nodes `rebuild()`. Used for one click `Level` rebuilding.
  - `SceneLoader` - async scene loading
  - `TeleportTrigger` - Teleports the player from a source location to a destination location. Can rotate the players Y axis.
  - `Trigger` - Triggers when a player passes through this. Can determine if x/y/z axis was crossed.

Basic additions to fps controller.
  - `teleport_in_relation_to` with y rotation
  - Interaction collider ray cast
  - Sitting/Standing
  - Disabling/Enabling input control

Basic Input Map Setup:
  - WASD movement
  - left/right click interact
  - space - jump
  - ctrl - crouch

Auto installs TrenchBroom, MESS, and Godot.

Scripts:
  - `compile-map.ps1` - Compiles a map located at `maps/main.map`. Will split the map up into layers based on the dictionary at `$MapTable`
  - `setup_dev.ps1` - Sets up the dev env. Windows only, for now... Installs Trenchbroom, MESS, and Godot, then copies relevant files to where they need to go
  - `run_editor.ps1` - Starts Godot. Clicking on `godot.exe` will launch the game itself, not the editor.

Made to quick start game jams easier. :D

TODO: 
  - Add multiple marking materials, add them to `PolygonMesh` ignored list.
  - Better player "disables"
  - MultiMeshScatter? Ghost? MultimeshDuplicator?
  - Make a trigger called `PlaneTrigger` that is allowed to take a marking/facing material to get a normal to find out if the player is on one side or the other of a plane.
  - Exclude `_dev` from being built into godot project.
  - Turn interact ray cast on and off (for fps, rather than fp)
