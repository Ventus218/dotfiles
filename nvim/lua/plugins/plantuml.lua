return {
    "charlesnicholson/plantuml.nvim",
    opts = {
        auto_start = true,
        auto_update = true,
        http_port = 8764,
        auto_launch_browser = "never", -- "always" or "once"

        -- -- Server
        -- plantuml_server_url = "http://www.plantuml.com/plantuml",

        -- Docker
        use_docker = true,
        docker_image = "plantuml/plantuml-server",
        docker_port = 8764,
        docker_remove_on_stop = true,
    },
}
