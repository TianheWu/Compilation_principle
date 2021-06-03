import os
import time
from collections import Counter
from typing import Set
import pyfiglet
import termtables as tt


title = pyfiglet.figlet_format("LR(0) Parsing Table", font="big")
authors = pyfiglet.figlet_format("Yuqing Chen ", font="doom")
print(title)
print(authors)


def add_dot(sentence: str) -> str:
    res = sentence.replace("->", "->.")
    return res


# Function to find closure of a product
def find_closure(product: str) -> list:
    closure = [product]
    for each_product in closure:
        letter_after_dot = each_product[each_product.index(".") + 1]

        # if the dot not on the last position
        if each_product.index(".") != len(each_product) - 1:
            for existed_product in products_rules:
                if existed_product[0] == letter_after_dot and (add_dot(existed_product)) not in closure:
                    closure.append(add_dot(existed_product))
        else:
            for existed_product in products_rules:
                if existed_product[0] == letter_after_dot and each_product not in closure:
                    closure.append(each_product)

    return closure


# A->.b  => A->b.
def postpone_char(new_value: str or list, target_pos: int) -> str:
    new_value = list(new_value)
    temp = new_value[target_pos]
    if target_pos != len(new_value):
        new_value[target_pos] = new_value[target_pos + 1]
        new_value[target_pos + 1] = temp
        newFinal = "".join(new_value)
        return newFinal
    else:
        return "".join(new_value)


def state_move(product: str) -> list or str:
    arr = []
    dot_pos = product.index(".")
    if dot_pos != len(product) - 1:
        product = list(product)
        new_product = postpone_char(product, dot_pos)
        if new_product.index(".") != len(new_product) - 1:
            closure = find_closure(new_product)
            return closure
        else:
            arr.append(new_product)
            return arr
    else:
        return product


def get_terminals(products: list) -> set:
    terminal_set = set()
    for p in products:
        x1 = p.split('->')
        for t in x1[1].strip():
            if not t.isupper() and t != '.' and t != '':
                terminal_set.add(t)

    terminal_set.add('#')

    return terminal_set


def get_non_terminals(products: list) -> set:
    non_terminals = set()
    for p in products:
        x1 = p.split('->')
        for t in x1[1].strip():
            if t.isupper():
                non_terminals.add(t)

    return non_terminals


def get_list(graph, state):
    final_list = []
    for g in graph:
        if int(g.split()[0]) == state:
            final_list.append(g)

    return final_list


products_rules = []  # products
closure_set = []    # temporary, to get the whole states
closures = []

with open("in.txt", 'r') as fp:
    for i in fp.readlines():
        products_rules.append(i.strip())

products_rules.insert(0, "X->.S")
print("---------------------------------------------------------------")
print("All Products")
print(products_rules)
time.sleep(2)

products_dict = {}  # dict <variable, index>
for i in range(1, len(products_rules)):
    products_dict[str(products_rules[i])] = i


closure_set.append(find_closure("X->.S"))

state_dict = {}  # dict <closure, state>
dfa_rules = {}
closure_numbers = 0


# get all states
while True:
    if len(closure_set) == 0:
        break

    top_closure = closure_set.pop(0)
    temp_closure = top_closure
    closures.append(top_closure)
    state_dict[str(top_closure)] = closure_numbers
    closure_numbers += 1
    if len(top_closure) > 1:
        for product in top_closure:
            new_closure = state_move(product)
            if new_closure not in closure_set and new_closure != temp_closure:
                closure_set.append(new_closure)
                dfa_rules[str(state_dict[str(top_closure)]) +
                          " " + str(product)] = new_closure
            else:
                dfa_rules[str(state_dict[str(top_closure)]) +
                          " " + str(product)] = new_closure

for closure in closures:
    for j in range(len(closure)):
        if state_move(closure[j]) not in closures:
            if closure[j].index(".") != len(closure[j]) - 1:
                closures.append(state_move(closure[j]))

print("---------------------------------------------------------------")
print("Total States: ", len(closures))
for i in range(len(closures)):
    print(i, ":", closures[i])
print("---------------------------------------------------------------")
time.sleep(2)


dfa = {}
for i in range(len(closures)):
    if i in dfa:
        pass
    else:
        lst = get_list(dfa_rules, i)
        temp = {}
        for j in lst:
            s = j.split()[1].split('->')[1]
            search = s[s.index('.') + 1]
            temp[search] = state_dict[str(dfa_rules[j])]

        if temp != {}:
            dfa[i] = temp

print(dfa)
time.sleep(2)


# print table
parsing_table = []
terminals = sorted(list(get_terminals(products_rules)))
header = [''] * (len(terminals) + 1)
header[0] = 'Action'

non_term = sorted(list(get_non_terminals(products_rules)))
header2 = [''] * len(non_term)
header2[0] = 'Goto'

parsing_table.append([''] + terminals + non_term)

parsing_table_dict = {}


for i in range(len(closures)):
    data = [''] * (len(terminals) + len(non_term))
    temp = {}

    # Action
    try:
        for j in dfa[i]:
            if not j.isupper() and j != '' and j != '.':
                ind = terminals.index(j)
                data[ind] = 'S' + str(dfa[i][j])
                temp[terminals[ind]] = 'S' + str(dfa[i][j])

    except Exception:
        if i != 1:
            s = list(closures[i][0])
            s.remove('.')
            s = "".join(s)
            lst = [i] + ['r' + str(products_dict[s])] * len(terminals)
            lst += [''] * len(non_term)
            parsing_table.append(lst)
            for j in terminals:
                temp[j] = 'r' + str(products_dict[s])
        else:
            lst = [i] + [''] * (len(terminals) + len(non_term))
            lst[-1] = 'Accept'
            parsing_table.append(lst)

    try:
        for j in dfa[i]:
            if j.isupper():
                ind = non_term.index(j)
                data[len(terminals) + ind] = dfa[i][j]

                temp[j] = str(dfa[i][j])

        parsing_table.append([i] + data)
    except Exception:
        pass

    if temp == {}:
        parsing_table_dict[i] = {'#': 'Accept'}
    else:
        parsing_table_dict[i] = temp


final_table = tt.to_string(data=parsing_table, header=header +
                           header2, style=tt.styles.ascii_thin_double, padding=(0, 2), alignment="l")

time.sleep(2)
print("\n")
print(final_table)
print("\n")

# ---------------- String Parsing ----------------

string = input("Enter the string to be parsed: ")
string += '#'
print("\n")

stack = [0]
pointer = 0

header = ['Process', 'Look Ahead', 'Symbol', 'Stack']
data = []

i = 0
accepted = False
while True:
    try:
        try:
            productions = dfa[stack[-1]]
            productions_number = productions[string[i]]
        except Exception:
            productions_number = None

        try:
            tab = parsing_table_dict[stack[-1]]
            tabCheck = tab[string[i]]  # S or r
        except Exception:
            tab = parsing_table_dict[stack[-2]]
            tabCheck = tab[stack[-1]]  # S or r

        if tabCheck == 'Accept':
            data.append(['Action({0}, {1}) = {2}'.format(
                stack[-1], string[i], tabCheck), i, string[i], str(stack)])
            accepted = True
            break
        else:
            if tabCheck[0] == 'S' and not str(stack[-1]).isupper():
                lst = ['Action({0}, {1}) = {2}'.format(
                    stack[-1], string[i], tabCheck), i, string[i]]
                stack.append(string[i])
                stack.append(productions_number)
                lst.append(str(stack))
                data.append(lst)
                i += 1
            elif tabCheck[0] == 'r':
                lst = ['Action({0}, {1}) = {2}'.format(
                    stack[-1], string[i], tabCheck), i, string[i]]
                x = None
                for i1 in products_dict:
                    if products_dict[i1] == int(tabCheck[1]):
                        x = i1
                        break

                length = 2 * (len(x.split('->')[1]))
                for _ in range(length):
                    stack.pop()

                stack.append(x[0])
                lst.append(str(stack))
                data.append(lst)

            else:
                lst = ['goto({0}, {1}) = {2}'.format(
                    stack[-2], stack[-1], tabCheck), i, string[i]]
                stack.append(int(tabCheck))
                lst.append(str(stack))
                data.append(lst)

    except Exception:
        accepted = False
        break


try:
    parsing_table = tt.to_string(
        data=data, header=header, style=tt.styles.ascii_thin_double, padding=(0, 2))

    if accepted:
        string = string[:-1]

        print(parsing_table)
        print("The string {0} is parsable!".format(string))

    else:
        print("The string {0} is not parsable!".format(string))

except Exception:
    print("Invalid string entered!")
