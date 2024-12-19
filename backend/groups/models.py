from django.db import models
from django.contrib.auth.models import User

class Group(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(User, related_name='created_groups', on_delete=models.CASCADE)

    def __str__(self):
        return self.name

class GroupMembership(models.Model):
    ROLE_CHOICES = [
        ('admin', 'Admin'),
        ('member', 'Member'),
    ]
    user = models.ForeignKey(User, related_name='memberships', on_delete=models.CASCADE)
    group = models.ForeignKey(Group, related_name='memberships', on_delete=models.CASCADE)
    joined_at = models.DateTimeField(auto_now_add=True)
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='member')

    class Meta:
        unique_together = ('user', 'group')

class Event(models.Model):
    group = models.ForeignKey(Group, related_name='events', on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    created_by = models.ForeignKey(User, related_name='created_events', on_delete=models.CASCADE)

    def __str__(self):
        return self.title

class GroupInvitation(models.Model):
    group = models.ForeignKey(Group, related_name='invitations', on_delete=models.CASCADE)
    user = models.ForeignKey(User, related_name='invitations', on_delete=models.CASCADE)
    invited_at = models.DateTimeField(auto_now_add=True)
    accepted = models.BooleanField(default=False)

    class Meta:
        unique_together = ('user', 'group')

class ChatMessage(models.Model):
    group = models.ForeignKey(Group, related_name='chat_messages', on_delete=models.CASCADE)
    user = models.ForeignKey(User, related_name='chat_messages', on_delete=models.CASCADE)
    message = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.user.username}: {self.message[:20]}'