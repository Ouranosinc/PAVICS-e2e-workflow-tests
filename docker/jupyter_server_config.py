c = get_config()  # noqa: F821
# When JupyterLab was launched behind JupyterHub default was ""frame-ancestors 'none'".
# JupyterLab launched standalone default was ""frame-ancestors 'self'".
c.ServerApp.tornado_settings={"headers":{"Content-Security-Policy": "frame-ancestors 'self'"}}
