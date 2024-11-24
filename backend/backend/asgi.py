import os
from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django_asgi_application = get_asgi_application()

from .routing import websocket_urlpatterns
from .jwt_middleware import JWTAuthMiddleware

application = ProtocolTypeRouter({
    'http': django_asgi_application,
    'websocket': JWTAuthMiddleware(
        URLRouter(
            websocket_urlpatterns
        )
    ),
})