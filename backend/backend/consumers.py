import json
import logging
from channels.generic.websocket import AsyncWebsocketConsumer

# Set up logging
logger = logging.getLogger(__name__)

class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope["user"]
        logger.debug(f"WebSocket connection attempt by user: {self.user}")
        if self.user.is_anonymous:
            logger.warning("Anonymous user tried to connect. Closing WebSocket.")
            await self.close()
        else:
            group_name = f"user_{self.user.id}"
            await self.channel_layer.group_add(
                group_name,
                self.channel_name
            )
            logger.info(f"User {self.user.id} added to group {group_name}.")
            await self.accept()

    async def disconnect(self, close_code):
        group_name = f"user_{self.user.id}"
        await self.channel_layer.group_discard(
            group_name,
            self.channel_name
        )
        logger.info(f"User {self.user.id} removed from group {group_name}.")

    async def receive(self, text_data):
        logger.debug(f"Received message from user {self.user.id}: {text_data}")
        # You can add handling for incoming messages here if needed.

    async def send_notification(self, event):
        logger.debug(f"Sending notification to user {self.user.id}: {event['message']}")
        await self.send(text_data=json.dumps(event["message"]))