from rest_framework import generics
from .models import Group, GroupMembership, Event
from django.db import models
from .serializers import GroupSerializer, GroupMembershipSerializer, EventSerializer
from rest_framework.response import Response
from rest_framework import status

class GroupListCreateView(generics.ListCreateAPIView):
    serializer_class = GroupSerializer

    def get_queryset(self):
        user = self.request.user
        return Group.objects.filter(
            models.Q(created_by=user) | models.Q(memberships__user=user)
        ).distinct()

    def perform_create(self, serializer):
        try:
            serializer.save(created_by=self.request.user)
        except Exception as e:
            print(f"Error creating group: {e}")
            raise

class GroupDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Group.objects.all()
    serializer_class = GroupSerializer

class GroupMembershipListCreateView(generics.ListCreateAPIView):
    queryset = GroupMembership.objects.all()
    serializer_class = GroupMembershipSerializer

class GroupMembershipDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = GroupMembership.objects.all()
    serializer_class = GroupMembershipSerializer

class EventListCreateView(generics.ListCreateAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer

class EventDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer