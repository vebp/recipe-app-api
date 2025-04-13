"""
Django command to wait for the database to be available
created to make sure db docker container is built
"""
from django.core.management.base import BaseCommand

class Command(BaseCommand):
    """
    Django command to wait for ddatabase.
    """

    def handle(self, *args, **options):
        pass