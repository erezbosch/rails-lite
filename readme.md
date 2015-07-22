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
CSRF protection: form_authenticity_token and protect_from_forgery functions
Params class
## Phase6:
invoke_action(name)
Router class
Route class
Extra CSRF code: call protect_from_forgery before invoking PUT/POST/DELETE reqs
## Flash:
Flash class, FlashNow class

# Bin files
## flash_test_server - tests flash/.now
## p05_params_server - tests auth
## csrf_test_server - better auth test
