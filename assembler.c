#include <stdio.h>
#include "uthash.h"
unsigned char bytes [10000];
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
    //printf("%02X\n", x);
    bytes[pc] = x;
    //printf("%02X %d\n", bytes[pc]);
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
    //printf("found label '%s', pc = %d\n", label, pc);
    add_symbol(label, pc);
  }
}

int find_label(char *label) {
  int label_pc = find_symbol(label);
  return label_pc;
}

int find_diff_label(char * label) {
  int label_pc = find_label(label);
  //printf("%d - %d = %d\n", label_pc, pc+1, label_pc - (pc+1));
  return label_pc - (pc+1);
}

void write_file() {
  FILE * out = fopen("out.gin", "w");
  fprintf(out, "type rom_type is array (%d downto 0) of std_logic_vector (8 downto 0);\n", pc-1);
  fprintf(out, "signal ROM : rom_type:=(");
  for(int i = 0; i < pc-1; ++i) { 
    if(i % 8 == 0) fputs("\n\t", out);
    fprintf(out, "X\"%02X\",", bytes[i]);
  }
  fprintf(out, "X\"%02X\"", bytes[pc-1]);
  fprintf(out, ");");
}
//TODO free hashmap memory
