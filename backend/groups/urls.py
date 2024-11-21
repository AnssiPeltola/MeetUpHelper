from django.urls import path
from .views import (
    DeleteGroupView, GroupListCreateView, GroupDetailView, GroupMembersView,
    GroupMembershipListCreateView, GroupMembershipDetailView,
    EventListCreateView, EventDetailView, EventCreateView, InviteUserView, AcceptInvitationView, KickUserView, NewInvitationsCountView, RejectInvitationView, ListInvitationsView
)

urlpatterns = [
    path('', GroupListCreateView.as_view(), name='group-list-create'),
    path('<int:pk>/', GroupDetailView.as_view(), name='group-detail'),
    path('<int:pk>/delete/', DeleteGroupView.as_view(), name='delete-group'),
    path('memberships/', GroupMembershipListCreateView.as_view(), name='membership-list-create'),
    path('memberships/<int:pk>/', GroupMembershipDetailView.as_view(), name='membership-detail'),
    path('events/', EventListCreateView.as_view(), name='event-list-create'),
    path('events/<int:pk>/', EventDetailView.as_view(), name='event-detail'),
    path('events/create/', EventCreateView.as_view(), name='event-create'),
    path('invite/', InviteUserView.as_view(), name='invite-user'),
    path('invite/accept/', AcceptInvitationView.as_view(), name='accept-invitation'),
    path('invite/reject/', RejectInvitationView.as_view(), name='reject-invitation'),
    path('invitations/', ListInvitationsView.as_view(), name='list-invitations'),
    path('kick/<int:pk>/', KickUserView.as_view(), name='kick-user'),
    path('<int:pk>/members/', GroupMembersView.as_view(), name='group-members'),
    path('invitations/count/', NewInvitationsCountView.as_view(), name='new-invitations-count'),
]