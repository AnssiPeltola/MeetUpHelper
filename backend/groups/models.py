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
    user = models.ForeignKey(User, related_name='memberships', on_delete=models.CASCADE)
    group = models.ForeignKey(Group, related_name='memberships', on_delete=models.CASCADE)
    joined_at = models.DateTimeField(auto_now_add=True)

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