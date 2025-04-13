"""
Test custom Django management commands.
"""
from unittest.mock import patch
from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command #allows to simulate to call the command
from django.db.utils import OperationalError
from django.test import SimpleTestCase

@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):
    """Test commands."""

    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for database if database ready."""
        patched_check.return_value = True

        call_command('wait_for_db')

        patched_check.assert_called_once_with(database=['default'])

    #NOTE: we want to check the database, wait a few seconds and check again. In reality we would wait, but not on the test, which just slow down the testing, plus we have the results
    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database when getting OperationalError."""
        patched_check.side_effect = [Psycopg2Error] * 2 + \
            [OperationalError] * 3 + [True] # [Psycopg2Error, Psycopg2Error, OperationalError, OperationalError, OperationalError, True]
        
        call_command('wait_for_db')
        
        self.assertEqual(patched_check.call_count, 6)
        patch_check.assert_called_once_with(database=['default'])