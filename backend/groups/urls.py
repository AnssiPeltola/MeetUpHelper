from django.urls import path
from .views import (
    GroupListCreateView, GroupDetailView,
    GroupMembershipListCreateView, GroupMembershipDetailView,
    EventListCreateView, EventDetailView
)

urlpatterns = [
    path('', GroupListCreateView.as_view(), name='group-list-create'),
    path('<int:pk>/', GroupDetailView.as_view(), name='group-detail'),
    path('memberships/', GroupMembershipListCreateView.as_view(), name='membership-list-create'),
    path('memberships/<int:pk>/', GroupMembershipDetailView.as_view(), name='membership-detail'),
    path('events/', EventListCreateView.as_view(), name='event-list-create'),
    path('events/<int:pk>/', EventDetailView.as_view(), name='event-detail'),
]