int leaf(int x) {
    return x + 1;
}

int level1(int x) {
    return leaf(x);
}

int level2(int x) {
    return level1(x);
}

int level3(int x) {
    return level2(x);
}
