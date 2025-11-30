from apps.common import utils as common_utils


class ObjectStatusTypeChoices(common_utils.GetString):
    DELETED = 0
    ACTIVE = 1
    CHOICES = (
        (DELETED, "Deleted"),
        (ACTIVE, "Active"),
    )