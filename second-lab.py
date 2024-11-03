import textwrap

from sqlalchemy.util import ellipses_string
from swiplserver import PrologMQI
from colorama import init, Fore, Style

'''
 Development part of the project
'''

# colorama initialization
init(autoreset=True)

# usable constants
SEPARATOR = "~" * 96
TABLE_SEPARATOR = "-" * 48
GREEN_SEPARATOR = f"{Fore.GREEN}{SEPARATOR}"
RED_SEPARATOR = f"{Fore.RED}{SEPARATOR}"
YELLOW_SEPARATOR = f"{Fore.YELLOW}{SEPARATOR}"
BLUE_SEPARATOR = f"{Fore.BLUE}{SEPARATOR}"
RED = f"{Fore.RED}"
GREEN = f"{Fore.GREEN}"
YELLOW = f"{Fore.YELLOW}"
BOLD = f"{Style.BRIGHT}"
GREEN_TABLE_SEPARATOR = f"{Fore.GREEN}{TABLE_SEPARATOR}{Style.RESET_ALL}"
HALF_GREEN_TABLE_SEPARATOR = f"{Fore.GREEN}{TABLE_SEPARATOR[21:]}{Style.RESET_ALL}"
TABLE_HEADER = f"{Fore.GREEN}{Style.BRIGHT}"
RESET = f"{Style.RESET_ALL}"
HIGHLIGHT = f"{Style.BRIGHT}{Fore.LIGHTWHITE_EX}"
HEADER_STYLE = f"{Fore.GREEN}{Style.BRIGHT}"
COLUMN_SEPARATOR = f"{Style.BRIGHT}{Fore.GREEN}|{Style.RESET_ALL}"
HELP = (
    " 1. 'list all residents' - to list all residents of Pelican Town\n"
    " 2. 'list gifts' - to list all gifts and their effects\n"
    " 3. 'list all friends' - to list all friendships\n"
    " 4. 'friends of <resident>' - to list all friends of a certain resident\n"
    " 5. 'make friends <resident> <resident>' - to make two residents friends\n"
    " 6. 'residents by <age> | <gender> | <name>' - to list all residents by certain criteria\n"
    " 7. 'spouse of <resident>' - to find the spouse of a certain resident\n"
    " 8. 'all spouses' - to list all spouses in Pelican Town\n"
    " 9. 'children of <resident>' - to find the children of a certain resident\n"
    " 10. 'parents of <resident>' - to find the parents of a certain resident\n"
    " 11. 'siblings of <resident>' - to find the siblings of a certain resident\n"
    " 12. 'gave gift from <resident> to <resident>' - to record a gift given by a resident\n"
    " 13. 'help' or 'h' - to display this message\n"
    " 14. 'exit' - to exit the program")


# helper functions
def display_not_found_message(person):
    person = " ".join(person.split(" ", 2)[2:]) if len(person.split()) > 1 else person
    print(f"{RED_SEPARATOR}\n Resident {HIGHLIGHT}{person}{RESET}{RED} not found.\n{SEPARATOR}\n")


def unknown_command():
    print(f"{RED_SEPARATOR}\n {BOLD}{RED}Unknown command.{RESET} Please, type 'help' or 'h' to see available commands."
          f"\n{RED_SEPARATOR}\n")


def print_table(criteria, residents_list):
    criteria_name = criteria[0]
    print(f"{GREEN_SEPARATOR}\n")
    criteria_argument = criteria[1]
    print(f" {HEADER_STYLE} Residents with {criteria_name} <{criteria_argument}>:\n"
          f" {HALF_GREEN_TABLE_SEPARATOR}\n {TABLE_HEADER}| {'ID':<2} | {criteria_name:<17} "
          f" |{RESET}\n {HALF_GREEN_TABLE_SEPARATOR}")
    for index, resident in enumerate(residents_list, start=1):
        id = str(index).ljust(2)
        name = resident['Name'].center(18)

        print(f" {COLUMN_SEPARATOR} {HEADER_STYLE}{id}{Style.RESET_ALL} {COLUMN_SEPARATOR} {name} {COLUMN_SEPARATOR}")
    print(f" {HALF_GREEN_TABLE_SEPARATOR}\n")

# wrapper for fixed width output
def line_wrap(message):
    wrapped_lines = [textwrap.fill(line, width=96) for line in message.split('\n')]
    for wrapped_line in wrapped_lines:
        print(wrapped_line)

# greeting function
def greeting():
    print(Fore.GREEN + SEPARATOR)
    message = (" Welcome to the small and broken Stardew Valley AI-draft!\n \n "
               "Here you can find some useful information about the residents of Pelican Town "
               "and to be the master of their destinies! (in some ways)\n ")

    line_wrap(message)
    print(Style.BRIGHT + " To know more about available commands type 'help' or 'h'.")
    print(Fore.GREEN + SEPARATOR, "\n")


def h(prolog_thread):
    print(Fore.GREEN + SEPARATOR)
    print(Style.BRIGHT + Fore.GREEN + " Available commands:\n" + Style.RESET_ALL + HELP)
    print(Fore.GREEN + SEPARATOR + "\n")


def list_all_residents(prolog_thread):
    residents_list = prolog_thread.query(f"resident(Name, Gender, Age).")
    print(f"{Fore.GREEN}{Style.BRIGHT} Residents of Pelican Town:\n"
          f"{Fore.GREEN} {TABLE_SEPARATOR}\n{Style.BRIGHT} | {'ID':<2} | {'Name':<11} "
          f"| {'Age':<13} | {'Gender':<9} |\n{Fore.GREEN} {TABLE_SEPARATOR}")
    for index, resident in enumerate(residents_list, start=1):
        id = str(index).ljust(2)
        name = resident['Name'].ljust(11)
        age = resident['Age'].ljust(13)
        gender = resident['Gender'].ljust(9)

        print(f" {COLUMN_SEPARATOR} {HEADER_STYLE}{id}{RESET} {COLUMN_SEPARATOR} {name} "
              f"{COLUMN_SEPARATOR} {age} {COLUMN_SEPARATOR} {gender} {COLUMN_SEPARATOR}")

    print(f"{GREEN_TABLE_SEPARATOR}\n")


def list_gifts(prolog_thread):
    gifts_list = prolog_thread.query(f"gift_effect(Gift, Effect).")
    print(f"{Fore.GREEN}{Style.BRIGHT} Available gifts  and their effects:\n"
          f"{Fore.GREEN} {TABLE_SEPARATOR}\n{Style.BRIGHT} | {'ID':<5} | {'Gift':<22} "
          f"| {'Effect':<11} |\n{Fore.GREEN} {TABLE_SEPARATOR}")

    for index, gifts in enumerate(gifts_list, start=1):
        id = str(index).center(5)
        gift = gifts['Gift'].center(22)
        if gifts['Effect'] < 0:
            effect = str(gifts['Effect']).center(10) + " "
        else:
            effect = str(gifts['Effect']).center(11)

        print(f" {COLUMN_SEPARATOR} {Fore.GREEN}{id}{Style.RESET_ALL} {COLUMN_SEPARATOR} {gift} "
              f"{COLUMN_SEPARATOR} {effect} {COLUMN_SEPARATOR}")

    print(f"{Fore.GREEN} {TABLE_SEPARATOR}\n")


def list_all_friends(prolog_thread):
    residents = prolog_thread.query(f"resident(Name, _, _).")
    print(f"{Fore.GREEN}{Style.BRIGHT} All friendships in Pelican Town:\n"
          f"{Fore.GREEN} {TABLE_SEPARATOR}\n{Style.BRIGHT} | {'ID':<2} | {'Person':<11} | "
          f"{'Friends':<25} |\n {TABLE_SEPARATOR}")

    for index, person in enumerate(residents, start=1):
        friends_list = prolog_thread.query(f"friend('{person['Name']}', Friend).")
        id = str(index).ljust(2)

        if friends_list:
            person = person['Name'].center(11)
            friends = f" | ".join([friend['Friend'] for friend in friends_list]).center(25)
            print(
                f" {COLUMN_SEPARATOR} {id} {COLUMN_SEPARATOR} {Style.BRIGHT}{Fore.LIGHTWHITE_EX}{person}"
                f"{Style.RESET_ALL} {COLUMN_SEPARATOR} {Fore.LIGHTWHITE_EX}{Style.BRIGHT}{friends}"
                f" {COLUMN_SEPARATOR}")
        else:
            person = person['Name'].center(11)
            friends = "no friends".center(25)
            print(f" {COLUMN_SEPARATOR} {id} {COLUMN_SEPARATOR} {person}{Style.RESET_ALL} "
                  f"{COLUMN_SEPARATOR} {friends} {COLUMN_SEPARATOR}")

    print(f"{Fore.GREEN} {TABLE_SEPARATOR}\n")


def list_friends_of(prolog_thread, command):
    person = command.split(" ")[-1]
    if prolog_thread.query(f"resident('{person}', _, _)."):
        friends_list = prolog_thread.query(f"friendship_level('{person}', Friend, Level).")
        print(f"{Fore.GREEN}{SEPARATOR}\n {Style.BRIGHT}Friends of {person}:\n")
        if friends_list:
            for index, friend in enumerate(friends_list, start=1):
                print(
                    f" {index}. {Style.BRIGHT}{Fore.LIGHTWHITE_EX}{person}{Style.RESET_ALL} "
                    f"is friends with {Fore.LIGHTWHITE_EX}{Style.BRIGHT}{friend['Friend']}!"
                    f" {Style.RESET_ALL}Friendship level: {friend['Level']}.")
        else:
            print(f" {person} has no friends yet :(")
        print(f"{Fore.GREEN}{SEPARATOR}\n")
    else:
        display_not_found_message(person)


def make_friends(prolog_thread, command):
    friends = command.split(" ")[2:]
    person_1 = prolog_thread.query(f"resident('{friends[0]}', _, _).")
    person_2 = prolog_thread.query(f"resident('{friends[1]}', _, _).")
    if not person_1:
        display_not_found_message(friends[0])
    elif not person_2:
        display_not_found_message(friends[1])
    elif prolog_thread.query(f"friend('{friends[0]}', '{friends[1]}')."):
        print(f"{Fore.YELLOW}{SEPARATOR}\n Residents {Style.BRIGHT}{Fore.LIGHTWHITE_EX}{friends[0]}{Style.NORMAL}"
              f"{Fore.YELLOW} and {Style.BRIGHT}{Fore.LIGHTWHITE_EX}{friends[1]}{Style.NORMAL}{Fore.YELLOW} "
              f"are already friends.\n{SEPARATOR}\n")
    else:
        are_friends_now = prolog_thread.query(f"make_friends('{friends[0]}', '{friends[1]}').")
        if are_friends_now:
            print(f"{Fore.GREEN}{SEPARATOR}\n Residents {Style.BRIGHT}{Fore.LIGHTWHITE_EX}{friends[0]}"
                  f"{Style.NORMAL}{Fore.GREEN} and {Style.BRIGHT}{Fore.LIGHTWHITE_EX}{friends[1]}{Style.NORMAL}"
                  f"{Fore.GREEN} are now friends!\n{SEPARATOR}\n")
        else:
            print(f"{Fore.RED}{SEPARATOR}\n Something went wrong. Residents "
                  f"{Style.BRIGHT}{Fore.LIGHTWHITE_EX}{friends[0]}{Style.NORMAL}{Fore.RED} "
                  f"and {Style.BRIGHT}{Fore.LIGHTWHITE_EX}{friends[0]}{Style.NORMAL}{Fore.RED}"
                  f" are not friends.\n{SEPARATOR}\n")


def get_residents_by(prolog_thread, command):
    criteria = command.split(" ")[2:]
    valid_criteria = {'age', 'gender', 'name'}

    if criteria[0] not in valid_criteria:
        print(f"{RED_SEPARATOR}\n {BOLD}Invalid criteria.{RESET} Please, use <help> or <list all residents> "
              f"command\n{RED_SEPARATOR}\n")
        return

    query = ""
    if criteria[0] == 'age':
        query = f"resident(Name, _, {criteria[1]})."
    elif criteria[0] == 'gender':
        query = f"resident(Name, {criteria[1]}, _)."
    elif criteria[0] == 'name':
        query = f"resident('{criteria[1]}', _, _)."

    residents_list = prolog_thread.query(query)

    if not residents_list:
        if criteria[0] == 'name':
            print(f"{RED_SEPARATOR}\n Resident {HIGHLIGHT}{criteria[1]}{RESET}{RED} not found.\n{SEPARATOR}\n")
        else:
            print(
                f"{RED_SEPARATOR}\n Residents with {criteria[0]} {HIGHLIGHT}{criteria[1]}{RESET}{RED} not found.\n{SEPARATOR}\n")
        return

    if criteria[0] == 'name':
        print(f"{GREEN_SEPARATOR}\n Resident {HIGHLIGHT}{criteria[1]}{RESET}{GREEN} exists!\n{SEPARATOR}\n")
    else:
        print_table(criteria, residents_list)


def spouse_of(prolog_thread, command):
    person = command.split(" ")[-1] if len(command.split()) == 3 else False
    if prolog_thread.query(f"resident('{person}', _, _).") and person:
        spouse = prolog_thread.query(f"spouse('{person}', Spouse).")
        if spouse:
            print(f"{GREEN_SEPARATOR}\n {HIGHLIGHT}{person}{RESET}{GREEN} is married to "
                  f"{HIGHLIGHT}{spouse[0]['Spouse']}.\n{GREEN_SEPARATOR}\n")
        else:
            print(f"{YELLOW_SEPARATOR}\n {HIGHLIGHT}{person}{RESET}{YELLOW} is not married yet.\n{SEPARATOR}\n")
    else:
        display_not_found_message(command)


def all_spouses(prolog_thread):
    spouses = prolog_thread.query(f"spouse_canon(X, Y).")
    print(f"{GREEN_SEPARATOR}\n {Style.BRIGHT}All spouses in Pelican Town:\n")
    for index, spouse in enumerate(spouses, start=1):
        print(f" {GREEN}{index}. {HIGHLIGHT}{spouse['X']}{RESET} is married to "
              f"{HIGHLIGHT}{spouse['Y']}.")
    print(f"{GREEN_SEPARATOR}\n")


def children_of(prolog_thread, command):
    person = command.split(" ")[-1] if len(command.split()) == 3 else False

    if prolog_thread.query(f"resident('{person}', _, _).") and person:
        children = prolog_thread.query(f"parents('{person}', Child).")
        if children:
            children_list = f"{GREEN} and {RESET}{HIGHLIGHT}".join(child['Child'] for child in children)
            print(
                f"{GREEN_SEPARATOR}\n {HIGHLIGHT}{person}{RESET}{GREEN} has children: {HIGHLIGHT}{children_list}{RESET}\n {GREEN_SEPARATOR}\n")
        else:
            print(f"{YELLOW_SEPARATOR}\n {HIGHLIGHT}{person}{RESET}{YELLOW} has no children yet.\n{SEPARATOR}\n")
    else:
        display_not_found_message(command)


def parents_of(prolog_thread, command):
    child = command.split(" ")[-1] if len(command.split()) == 3 else False
    if prolog_thread.query(f"resident('{child}', _, _).") and child:
        children = prolog_thread.query(f"children('{child}', Parent).")
        if children:
            children_list = f"{GREEN} and {RESET}{HIGHLIGHT}".join(child['Parent'] for child in children)
            print(
                f"{GREEN_SEPARATOR}\n {HIGHLIGHT}{child}{RESET}{GREEN} is a child of {HIGHLIGHT}{children_list}{RESET}\n {GREEN_SEPARATOR}\n")
        else:
            print(
                f"{YELLOW_SEPARATOR}\n {HIGHLIGHT}{child}{RESET}{YELLOW} has no parents in Pelican Town.\n{SEPARATOR}\n")
    else:
        display_not_found_message(command)


def siblings_of(prolog_thread, command):
    person = command.split(" ")[-1] if len(command.split()) == 3 else False
    if prolog_thread.query(f"resident('{person}', _, _).") and person:
        sibling = prolog_thread.query(f"siblings('{person}', Sibling).")
        if sibling:
            print(
                f"{GREEN_SEPARATOR}\n {HIGHLIGHT}{person}{RESET}{GREEN} is a sibling of {HIGHLIGHT}{sibling[0]['Sibling']}{RESET}\n {GREEN_SEPARATOR}\n")
        else:
            print(
                f"{YELLOW_SEPARATOR}\n {HIGHLIGHT}{person}{RESET}{YELLOW} has no siblings in Pelican Town.\n{SEPARATOR}\n")
    else:
        display_not_found_message(command)


def gave_gift(prolog_thread, command):
    if len(command.split()) != 6:
        unknown_command()
        return False

    giver = command.split()[3]
    receiver = command.split()[5]
    if giver == receiver:
        print(f"{RED_SEPARATOR}\n {HIGHLIGHT}{giver}{RESET}{RED} can't give a gift to himself.\n{SEPARATOR}\n")
        return False

    if (prolog_thread.query(f"resident('{giver}', _, _).") and prolog_thread.query(f"resident('{receiver}', _, _).")):
        list_gifts(prolog_thread)
        print(f"{BLUE_SEPARATOR}")
        gift = input(" Choose the gift from the list above: ")
        print(f"{BLUE_SEPARATOR}\n")
        if prolog_thread.query(f"gave_gift('{giver}', '{receiver}', '{gift}')."):
            friendship_level = prolog_thread.query(f"friendship_level('{giver}', '{receiver}', Level).")[0]
            friends_status = prolog_thread.query(f"check_friendship_status('{giver}', '{receiver}',{friendship_level['Level']}).")
            if friends_status:
                print(f"{GREEN_SEPARATOR}\n {HIGHLIGHT}{giver}{RESET}{GREEN} gave {HIGHLIGHT}{gift}{RESET}{GREEN} to "
                      f"{HIGHLIGHT}{receiver}{RESET}{GREEN}! Friendship level: {HIGHLIGHT}{friendship_level['Level']}"
                      f"{RESET}{GREEN}.\n{GREEN_SEPARATOR}\n")
            else:
                print(f"{YELLOW_SEPARATOR}")
                message = (f" {HIGHLIGHT}{giver}{RESET}{YELLOW} gave {HIGHLIGHT}{gift}"
                           f"{RESET}{YELLOW} to {HIGHLIGHT}{receiver}{RESET}{YELLOW}!\n Their friendship level "
                           f"is not high enough.\n {HIGHLIGHT}{giver}{RESET}{YELLOW} and {HIGHLIGHT}{receiver}"
                           f"{RESET}{YELLOW} not friends anymore {HIGHLIGHT}:(")
                line_wrap(message)
                print(f"{YELLOW_SEPARATOR}\n")
        else:
            print(f"{RED_SEPARATOR}\n Gift {HIGHLIGHT}'{gift}'{RESET}{RED} not found.\n{SEPARATOR}\n")
    else:
        display_not_found_message(giver if not prolog_thread.query(f"resident('{giver}', _, _).") else receiver)


# dictionary with available commands
commands = {
    'help': h,
    'h': h,
    'list all residents': list_all_residents,
    'list gifts': list_gifts,
    'list all friends': list_all_friends,
    'all spouses': all_spouses
}

compound_commands = {
    'friends of': list_friends_of,
    'make friends': make_friends,
    'residents by': get_residents_by,
    'spouse of': spouse_of,
    'children of': children_of,
    'parents of': parents_of,
    'siblings of': siblings_of,
    'gave gift': gave_gift
}


# the heart of project (commands handler function)
def command_handler(prolog_thread, command):
    if command == 'exit' or command == 'Exit':
        return False
    elif command in commands:
        commands[command](prolog_thread)

    else:
        base_of_command = " ".join(command.split(" ", 2)[:2])
        if base_of_command in compound_commands:
            compound_commands[base_of_command](prolog_thread, command)
        else:
            unknown_command()

    return True


# main function
with (PrologMQI() as mqi):
    with mqi.create_thread() as prolog_thread:
        prolog_thread.query("consult('kb-edited.pl')")
        greeting()
        command = ''
        while command != 'exit':
            print(Fore.MAGENTA + SEPARATOR)
            command = input(" Enter your command: ")
            print(Fore.MAGENTA + SEPARATOR, "\n")
            if not command_handler(prolog_thread, command):
                exit(0)
