return {
    "charlesnicholson/plantuml.nvim",
    opts = {
        auto_start = true,
        auto_update = true,
        http_port = 8764,
        auto_launch_browser = "never", -- "always" or "once"

        -- Server
        plantuml_server_url = "http://localhost:11111",

        -- -- Docker
        -- use_docker = true,
        -- docker_image = "plantuml/plantuml-server",
        -- docker_port = 11111,
        -- docker_remove_on_stop = true,
    },
}
