int parse(int);
int validate(int);

int process(int x) {
    if (!validate(x))
        return -1;
    return parse(x);
}