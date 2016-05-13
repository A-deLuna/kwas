#include <stdio.h>
#include "uthash.h"
char bytes [10000];
int pc = 0;
int pass = 1;

struct symbol {
  char name[100];
  int value;
  UT_hash_handle hh;
};

struct symbol *symbol_table = NULL;

int count(int x) {
  int ans = 0;
  while(x >>= 1) {
    ans++;
  }
  return ans;
}

int concat(int x, int y) {
  return (x << count(y) + (4 - (count(y) %4 ))) | y;
}

int regreg(int r1, int r2) {
  return (r1 << 2) | r2;
}

int registers_number8(int r, int n) {
  return (r << 8 ) | n;
}

void wb(int x) {
  if(pass == 2) {
    x &= 0xff;
    printf("%02X\n", x);
    bytes[pc] = x;
  }
  pc++;
}

void write(int x) {
    if (x == 0) return;
    write(x >> 8);
    wb(x);
}

void add_symbol(char * n , int value) {
  struct symbol *s;
  s = (struct symbol*) malloc(sizeof(struct symbol));
  strncpy(s->name, n, 10);
  s->value = value;
  HASH_ADD_STR(symbol_table, name, s);
}

int find_symbol(char *n) {
  struct symbol *s;
  HASH_FIND_STR(symbol_table, n, s);
  if(s) {
    return s->value;
  }
  return -1;
}

void save_label(char* label) {
  if(pass == 1){
    printf("found label '%s', pc = %d\n", label, pc);
    add_symbol(label, pc);
  }
}

int find_label(char *label) {
  int label_pc = find_symbol(label);
  return label_pc;
}

int find_diff_label(char * label) {
  int label_pc = find_label(label);
}
//TODO free hashmap memory
