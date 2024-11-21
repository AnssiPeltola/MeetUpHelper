from rest_framework import generics, status
from .models import Group, GroupMembership, Event, GroupInvitation
from django.db import models
from django.contrib.auth.models import User
from .serializers import GroupSerializer, GroupMembershipSerializer, EventSerializer, GroupInvitationSerializer
from rest_framework.response import Response
import logging
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView

logger = logging.getLogger(__name__)

class GroupListCreateView(generics.ListCreateAPIView):
    serializer_class = GroupSerializer

    def get_queryset(self):
        user = self.request.user
        return Group.objects.filter(
            models.Q(created_by=user) | models.Q(memberships__user=user)
        ).distinct()

    def perform_create(self, serializer):
        try:
            group = serializer.save(created_by=self.request.user)
            GroupMembership.objects.create(user=self.request.user, group=group, role='admin')
        except Exception as e:
            print(f"Error creating group: {e}")
            raise

class GroupDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Group.objects.all()
    serializer_class = GroupSerializer

    def get(self, request, *args, **kwargs):
        group = self.get_object()
        serializer = self.get_serializer(group)
        return Response(serializer.data)
    
class DeleteGroupView(generics.DestroyAPIView):
    queryset = Group.objects.all()
    serializer_class = GroupSerializer

    def delete(self, request, *args, **kwargs):
        group = self.get_object()
        if group.created_by != request.user:
            return Response({'error': 'Only the group admin can delete the group.'}, status=status.HTTP_403_FORBIDDEN)
        group.delete()
        return Response({'message': 'Group deleted successfully'}, status=status.HTTP_204_NO_CONTENT)
    
class KickUserView(generics.DestroyAPIView):
    queryset = GroupMembership.objects.all()
    serializer_class = GroupMembershipSerializer

    def delete(self, request, *args, **kwargs):
        membership = self.get_object()
        group = membership.group
        if group.created_by != request.user:
            return Response({'error': 'Only the group admin can kick users.'}, status=status.HTTP_403_FORBIDDEN)
        membership.delete()
        return Response({'message': 'User kicked from group.'}, status=status.HTTP_200_OK)

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

class EventCreateView(generics.CreateAPIView):
    queryset = Event.objects.all()
    serializer_class = EventSerializer

    def perform_create(self, serializer):
        logger.debug(f"Creating event with data: {serializer.validated_data}")
        serializer.save(created_by=self.request.user)

class InviteUserView(generics.CreateAPIView):
    serializer_class = GroupInvitationSerializer

    def post(self, request, *args, **kwargs):
        group_id = request.data.get('group_id')
        email = request.data.get('email')

        try:
            group = Group.objects.get(id=group_id)
            user = User.objects.get(email=email)
            if GroupMembership.objects.filter(user=user, group=group).exists():
                return Response({'error': 'User is already a member of the group'}, status=status.HTTP_400_BAD_REQUEST)
            invitation, created = GroupInvitation.objects.get_or_create(user=user, group=group)
            if not created:
                return Response({'error': 'User already invited'}, status=status.HTTP_400_BAD_REQUEST)
            return Response({'message': 'User invited successfully'}, status=status.HTTP_201_CREATED)
        except Group.DoesNotExist:
            return Response({'error': 'Group not found'}, status=status.HTTP_404_NOT_FOUND)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
class AcceptInvitationView(generics.UpdateAPIView):
    queryset = GroupInvitation.objects.all()
    serializer_class = GroupInvitationSerializer

    def post(self, request, *args, **kwargs):
        invitation_id = request.data.get('invitation_id')

        try:
            invitation = GroupInvitation.objects.get(id=invitation_id)
            invitation.accepted = True
            invitation.save()
            GroupMembership.objects.create(user=invitation.user, group=invitation.group)
            invitation.delete()
            return Response({'message': 'Invitation accepted'}, status=status.HTTP_200_OK)
        except GroupInvitation.DoesNotExist:
            return Response({'error': 'Invitation not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

class RejectInvitationView(generics.UpdateAPIView):
    queryset = GroupInvitation.objects.all()
    serializer_class = GroupInvitationSerializer

    def post(self, request, *args, **kwargs):
        invitation_id = request.data.get('invitation_id')

        try:
            invitation = GroupInvitation.objects.get(id=invitation_id)
            invitation.delete()
            return Response({'message': 'Invitation rejected'}, status=status.HTTP_200_OK)
        except GroupInvitation.DoesNotExist:
            return Response({'error': 'Invitation not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
class ListInvitationsView(generics.ListAPIView):
    serializer_class = GroupInvitationSerializer

    def get_queryset(self):
        user = self.request.user
        return GroupInvitation.objects.filter(user=user)
    
class GroupMembersView(generics.ListAPIView):
    serializer_class = GroupMembershipSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        group_id = self.kwargs['pk']
        return GroupMembership.objects.filter(group_id=group_id)
    
class NewInvitationsCountView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        new_invitations_count = GroupInvitation.objects.filter(user=user, accepted=False).count()
        return Response({'new_invitations_count': new_invitations_count})