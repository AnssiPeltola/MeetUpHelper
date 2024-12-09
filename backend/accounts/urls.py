from django.urls import path
from .views import CurrentUserView, RegisterView, UserDetailView
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('register/', RegisterView.as_view(), name="register"),
    path('login/', TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path('token/refresh/', TokenRefreshView.as_view(), name="token_refresh"),
    path('me/', CurrentUserView.as_view(), name='current-user'),
    path('user/<int:user_id>/', UserDetailView.as_view(), name='user-detail'),
]