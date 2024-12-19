import json
import logging
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth.models import User
from groups.models import Group, ChatMessage

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

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.group_id = self.scope['url_route']['kwargs']['group_id']
        self.group_name = f'group_{self.group_id}'
        self.user = self.scope["user"]

        if self.user.is_anonymous:
            await self.close()
        else:
            await self.channel_layer.group_add(
                self.group_name,
                self.channel_name
            )
            await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(
            self.group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data['message']

        chat_message = await self.save_message(self.user, self.group_id, message)

        await self.channel_layer.group_send(
            self.group_name,
            {
                'type': 'chat_message',
                'message': chat_message.message,
                'user': chat_message.user.username,
                'timestamp': chat_message.timestamp.isoformat(),
            }
        )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            'message': event['message'],
            'user': event['user'],
            'timestamp': event['timestamp'],
        }))

    @database_sync_to_async
    def save_message(self, user, group_id, message):
        group = Group.objects.get(id=group_id)
        return ChatMessage.objects.create(user=user, group=group, message=message)