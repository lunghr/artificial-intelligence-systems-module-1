from colorama import Fore, Style
from swiplserver import PrologMQI

'''
 Drafts and testing part of the project
'''


def make_friends(person, friend):
    return prolog_thread.query(f"make_friends({person}, {friend}).")

def list_all_residents(prolog_thread):
    residents_list = prolog_thread.query(f"resident(Name, Sex, Age).")
    print(Style.BRIGHT + Fore.GREEN + " Residents of Pelican Town:")
    for resident in residents_list:
        print(resident)

def list_gifts():
    return prolog_thread.query(f"gift_effect(X, Y).")
    # return prolog_thread.query(f"list_gifts(X).")




with (PrologMQI() as mqi):
    with mqi.create_thread() as prolog_thread:
        prolog_thread.query("consult('kb-edited.pl')")

        person = "haley"
        friend = "sam"
        result = list_gifts()
        for item in result:
            print(f'Gift: {item["X"]}, Effect: {item["Y"]}')
