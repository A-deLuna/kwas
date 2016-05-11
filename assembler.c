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

