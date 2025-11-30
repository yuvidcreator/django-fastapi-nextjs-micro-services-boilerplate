import uuid


class GetString(object):
    @classmethod
    def get_choice_string(cls, choice):
        dictchoice = dict(cls.CHOICES)
        str = dictchoice[choice]
        return str
    
    @classmethod
    def all(cls):
        return [{"key":name,"key_display_name":cls.get_choice_string(value),"value":value} for name, value in vars(cls).items() if name.isupper() and name != "CHOICES"]
    
    @classmethod
    def get_value_by_name(cls, name):
        dictchoice = dict(cls.CHOICES)
        for key, value in dictchoice.items():
            if value.lower() == name.lower():
                return key
    

def users_profile_upload_path(instance, filename):
    date_format = instance.updated_at.strftime("%Y%m%d%H%M%S")
    undt = f"""{date_format}"""

    ext = filename.split(".")[-1]
    # get filename
    if instance.pk:
        file = f"{instance.pk}.webp"
        return 'users/{mobile}/{updt}-{newfile}'.format(mobile=instance.mobile, updt=undt, newfile=file)
    else:
        file = f"{uuid.uuid4().hex}.webp"
    return 'user-service/users_profiles/{mobile}/{newfile}'.format(mobile=instance.mobile, newfile=file)



def profilebanner_upload_path(instance, filename):
    date_format = instance.updated_at.strftime("%Y%m%d%H%M%S")
    undt = f"""{date_format}"""

    ext = filename.split(".")[-1]
    # get filename
    if instance.pk:
        file = f"{instance.pk}.webp"
    else:
        file = f"{uuid.uuid4().hex}.webp"
    return 'user-service/profilebanners/{id}/{updt}-{newfile}'.format(id=instance.id, updt=undt, newfile=file)




# def pages_upload_path(instance, filename):
#     date_format = instance.updated_at.strftime("%Y%m%d%H%M%S")
#     undt = f"""{date_format}"""

#     ext = filename.split(".")[-1]
#     # get filename
#     if instance.pk:
#         file = f"{instance.pk}.webp"
#     else:
#         file = f"{uuid.uuid4().hex}.webp"
#     return 'pages/{id}/{updt}-{newfile}'.format(id=instance.id, updt=undt, newfile=file)




