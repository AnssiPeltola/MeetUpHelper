from rest_framework import serializers
from .models import Group, GroupMembership, Event, GroupInvitation, ChatMessage
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = '__all__'
        extra_kwargs = {
            'created_by': {'read_only': True},
        }

class GroupSerializer(serializers.ModelSerializer):
    created_by = UserSerializer(read_only=True)
    events = EventSerializer(many=True, read_only=True)

    class Meta:
        model = Group
        fields = '__all__'
        extra_kwargs = {
            'created_by': {'read_only': True},
        }

class GroupMembershipSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = GroupMembership
        fields = '__all__'

class GroupInvitationSerializer(serializers.ModelSerializer):
    group = GroupSerializer(read_only=True)
    user = UserSerializer(read_only=True)

    class Meta:
        model = GroupInvitation
        fields = '__all__'

class ChatMessageSerializer(serializers.ModelSerializer):
    user = serializers.PrimaryKeyRelatedField(read_only=True)
    group = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = ChatMessage
        fields = ['id', 'group', 'user', 'message', 'timestamp']