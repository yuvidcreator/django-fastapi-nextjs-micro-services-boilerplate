from apps.common import utils as common_utils



class UserGenderChoices(common_utils.GetString):
    MALE = "male"
    FEMALE = "female"
    OTHERS = "others"

    CHOICES = [
        (MALE, "Male"),
        (FEMALE, "Female"),
        (OTHERS, "Others"),
    ]