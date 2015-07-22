# Organization
## Phase2:
ControllerBase#initialize, already_built_response?, render_content, redirect_to
## Phase3:
render_template
## Phase4:
redirect_to, render_content overwritten to include Session and Flash cookies
Session and Flash accessors
## Phase5:
attr_reader for params, initialize overwritten to include params hash
Params class
## Phase6:
invoke_action(name)
Router class
Route class
## Flash:
Flash class, FlashNow class
