function levenshtein(s, t) {
  if (s === t) {
    return 0;
  }
  var n = s.length, m = t.length;
  if (n === 0 || m === 0) {
    return n + m;
  }
  var x = 0, y, a, b, c, d, g, h, k;
  var p = new Array(n);
  for (y = 0; y < n;) {
    p[y] = ++y;
  }

  for (; (x + 3) < m; x += 4) {
    var e1 = t.charCodeAt(x);
    var e2 = t.charCodeAt(x + 1);
    var e3 = t.charCodeAt(x + 2);
    var e4 = t.charCodeAt(x + 3);
    c = x;
    b = x + 1;
    d = x + 2;
    g = x + 3;
    h = x + 4;
    for (y = 0; y < n; y++) {
      k = s.charCodeAt(y);
      a = p[y];
      if (a < c || b < c) {
        c = (a > b ? b + 1 : a + 1);
      }
      else {
        if (e1 !== k) {
          c++;
        }
      }

      if (c < b || d < b) {
        b = (c > d ? d + 1 : c + 1);
      }
      else {
        if (e2 !== k) {
          b++;
        }
      }

      if (b < d || g < d) {
        d = (b > g ? g + 1 : b + 1);
      }
      else {
        if (e3 !== k) {
          d++;
        }
      }

      if (d < g || h < g) {
        g = (d > h ? h + 1 : d + 1);
      }
      else {
        if (e4 !== k) {
          g++;
        }
      }
      p[y] = h = g;
      g = d;
      d = b;
      b = c;
      c = a;
    }
  }

  for (; x < m;) {
    var e = t.charCodeAt(x);
    c = x;
    d = ++x;
    for (y = 0; y < n; y++) {
      a = p[y];
      if (a < c || d < c) {
        d = (a > d ? d + 1 : a + 1);
      }
      else {
        if (e !== s.charCodeAt(y)) {
          d = c + 1;
        }
        else {
          d = c;
        }
      }
      p[y] = d;
      c = a;
    }
    h = d;
  }
  return h;
}

export function mail2string(outData) {
  let mailS = '';
  outData.blocks.forEach(b => {
	mailS += b.data['text'] + "\n";
  });
  return mailS;
};

export function block_distance(curr_email,prev_email){
  var resp = new Object();
  resp.b = 0;
  resp.text = '';
  let t = curr_email.time - prev_email.time;
  if(t < 3){
	return resp;
  }
  for (let i = 0; i < curr_email.blocks.length; ++i) {
	let h = levenshtein(curr_email.blocks[i].data['text']
						,prev_email.blocks[i].data['text']);
	if(h > 3){
	  console.log('block ',curr_email.blocks[i]['id'],' changed by ',h,'position',i);
	  resp.b = i;
	  resp.text = curr_email.blocks[i].data['text'];
	  return resp;
	}
  }
  return resp;
}

function mail_distance(curr_email,prev_email){
  let h = levenshtein(currS,prevS);
  let t = curr_email.time - prev_email.time;
  console.log('distance ',h,' time ',t);
  return h
}


