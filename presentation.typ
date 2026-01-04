#import "./theme/fcb.typ": *
#import "@preview/cades:0.3.1": qr-code
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
// #codly(zebra-fill: none)
#codly(number-format: none) // #codly(number-format: it => [#it])
#codly(languages: codly-languages)

#let background = white // silver
#let foreground = black
#let primary = rgb(56, 59, 83)
#let link-background = rgb(255, 178, 178).darken(40%)
#let header-footer-foreground = rgb(255, 178, 178).darken(40%)

#show: fcb-theme.with(
  aspect-ratio: "16-9",
  header: [#align(
    center,
  )[_On Optimally Partitioning a Text to Improve Its Compression_]],
  footer: [Davide Cologni -- Ca' Foscari University of Venice],
  background: background,
  foreground: foreground,
  primary: primary,
  link-background: link-background,
  header-footer-foreground: header-footer-foreground,
)

#let tiny-size = 0.4em
#let small-size = 0.7em
#let normal-size = 1em
#let large-size = 1.3em
#let huge-size = 1.6em

#title-slide[
  = On Optimally Partitioning a Text to Improve Its Compression

  #v(1em)

  Davide Cologni, #footnote[
      RAVEN Group -- Ca' Foscari University of Venice, \
      #h(1.5em) Github: #link("https://github.com/colobrodo")[github.com/colobrodo], \
      #h(1.5em) Email: #link("mailto:davide.cologni@unive.it")[davide.cologni\@unive.it] \
    ] PhD Candidate

    Venice, Italy -- #datetime.today().display("[day] [month repr:long] [year repr:full]")
]


#centered-slide[
  = Problem: Text Partitioning

  #v(1em)

  #align(horizon + center)[
    We have a compressor $cal(C)$ and a Text $T$ of size $n$, it's possible to divide $T$ into $k <= n$ parts, $T[1..i_1-1]T[i_1..i_2-1]...T[i_(k-1)..n]$ and compress each of them individually with $cal(C)$ to improve the overall compression?
    
    Intuitively we can group the most similar parts of the string together so each partition is better compressed by $cal(C)$.
    
    We do *not* permute the string we are only interested on partitioning it. 
  ]
]

#centered-slide[
  = Text Partitioning Example

  #v(1em)

  #align(horizon + center)[
    TODO
  ]
]

#centered-slide[
  = Reduction to SSSP
  We can model each partition problem as a directed graph with $n + 1$ vertices, where an edge exists between $v_i$ and $v_j$ only if $ 1 <= i < j <= n + 1 $ 

  #figure(
    image("images/reduction.svg", width: 75%),
  ) <reduction>
  

]

#centered-slide[
  = Reduction to SSSP - Bijection between paths and partitions

  #v(1em)

  #one-by-one(start: 1)[
    We can then show that there exists a bijection from each path $pi = (v_1, v_i_1) ... (v_i_k, v_(n+1))$ in the graph, and the partitioning of the text $T$ in the form $T[1..i_1-1]T[i_1..i_2-1]...T[i_(k-1)..n]$
  ]

  #figure(
    image("images/bijection2.svg", width: 80%),
    caption: [We can map the path $pi=$ #box(fill: rgb(255, 178, 178).transparentize(10%))[$(v_1, v_4)$] #box(fill: rgb(178, 178, 255).transparentize(30%))[$(v_4, v_6)$] to the partitioning of the string #box(fill: rgb(255, 178, 178).transparentize(10%))[$T[1, 3]$]
    #box(fill: rgb(178, 178, 255).transparentize(30%))[$T[4, 5]$]],
  ) <bijection>

]

#centered-slide[
  = Reduction to SSSP - Bijection between paths and partitions

  #v(2em)

  #one-by-one(start: 1)[
    If we weight each edge $(i, j)$ of the graph by the cost of compressing the corresponding text segment $w(i, j) = cal(C)(T[i, j-1])$, we can solve the partitioning problem _optimally_ computing the *Single Source Shortest Path (SSSP)*

    It can be computed efficiently in $O(|E|)$ time using a classic dynamic programming algorithm. 
  ]

]

#focus-slide[
  *Problems:*
  #v(0.5em)
  1. Our graph has $O(n^2)$ nodes by construction
  2. To initialize the weight $w(i, j)$ we should execute $cal(C)$ on every substring of the text
]

#centered-slide[
  = Assumption on $cal(C)$

  #v(0.5em)

  - Our compressor is _monotonic_: the compressed output on a suffix or a prefix of the string is always smaller than the compression on the whole string: 
  $cal(C)(T[i, j]) >= cal(C)(T[i, j - 1])$
  
  $cal(C)(T[i, j]) >= cal(C)(T[i + 1, j])$
  
  - We can compute the size of the compressed output incrementally: computing $cal(C)(T[i, j])$ from $cal(C)(T[i - 1, j])$ or $cal(C)(T[i, j - 1])$ take constant time
]

#centered-slide[
  = Monotonicity of $w$

  Due to the monotonicity of the compressor for every node $1 <= i < k < j <= n + 1$ we have that $w(i, k) <= w(i, j)$

  #figure(
    image("images/monotonicity.svg", width: 60%),
  ) <monotonicity>
]

#centered-slide[
  = Sparsification of the DAG

  #v(1em)

  Thanks to this property we can obtain an approximated algorithm by *sparsifing* the graph thus selecting only some edges.

  We are able to obtain a $(1 + epsilon)$-approximation, for every $epsilon >= 0$, with a time complexity of $O(n log_(1 + epsilon) L)$ 
  
  where $L = w(1, n)$, so the cost of compressing the entire text.

  This algorithm can be applied to every dynamic programming algorithm in the form $E[j] = min_(1 <= i < j)\(E[i] + w(i, j)\)$ when $w$ is _monotone_!

]

#simple-slide[
  = Key Idea: $epsilon$-maximal edges

  #v(0.5em)

  #align(center)[*How we can select some edges to obtain the $(1 + epsilon)$ approximation factor?*]
  
  For each node $i$ select the $epsilon$-maximal edges, so the outgoing edge from $i$ that satisfy one of these conditions:
  - The edges $(i, j)$ such that $w(i, j) <= (1 + epsilon)^k < w(i, j + 1)$ for any integer $k >= 1$
  - The last outgoing edge: $(i, n + 1)$
]

#centered-slide[
  So we select the best approximations of the powers of $(1 + epsilon)$ from below: We then have at most $log_(1+epsilon) L$ outgoing edges for each node.

  
  #figure(
    image("images/maximal-eps.svg", width: 65%),
  ) <maximal-eps>
]

#simple-slide[

  Each edge is then _"covered"_ by an $epsilon$-maximal edge: The weight of the edge is then approximated by $(1 + epsilon)$ times the weight of the maximal edge that covers it. 


  #figure(
    image("images/eps-max-covering.svg", width: 90%),
  ) <eps-max-covering>

]



#simple-slide[
  == Lemma 1
  Let $d_cal(G)(i)$ be the cost of the shortest path in our graph $cal(G)$ from $v_i$ to $v_(n+1)$ then

  For all the vertices $i, j: 1 <= i < j <= n + 1$, $d_cal(G)(i) >= d_cal(G)(j)$

  *Proof by induction:*
  - Base, trivial case for $n + 1$
  - Then we need to show that $d_cal(G)(i) >= d_cal(G)(i + 1)$
  #v(2em)

  Let $d_cal(G)(i)$ be $(v_i, v_t_1)(v_t_1, v_t_2)...(v_t_k, v_(n+1))$ 
    - Trivial if $t_1 = i + 1$
    - If $t_1 > i + 1$ then we can construct a shortest path $(v_(i+1), v_t_1)(v_t_1, v_t_2)...(v_t_k, v_(n+1))$ because thanks to the definition of _monotonicity_ we know that $w(i, t_1) >= w(i + 1, t_1)$ 

    #figure(
      image("images/shortest-path.svg", width: 60%),
    ) <shortest-path>
]

#simple-slide[
  = Theorem
  Let $cal(G)_epsilon$ be the graph containing only $epsilon$-maximal edges, then $d_(cal(G)_epsilon)(i) <= (1 + epsilon)d_(cal(G))(i)$ for every $1 <= i <= n + 1$.

  // I should say induction on what
  *Proof by induction:*
  - *Base*, trivial case for $n + 1$ 
  - Then let $pi(i) = (v_i, v_t_1) .. (v_t_h, v_n)$ the shortest path starting from node $v_i$ and let $d_cal(G) = w(i, t_1) + d_cal(G)(t_1)$ be its cost.
    We choose the $epsilon$-maximal node $r$ that covers $t_1$: 
    So $r > t_1$ and we already know that #par(first-line-indent: 1em, $w(i, r) <= (1 + epsilon)w(i, t_1)$) 
    
    By _Lemma 1_: \ #par(first-line-indent: 1em,
$d_cal(G)(r) <= d_cal(G)(t_1) $) 
  
    By inductive hypothesis: \ 
    #par(first-line-indent: 1em, $d_cal(G)_epsilon (r) <= (1 + epsilon)d_cal(G)(r) <= (1 + epsilon)d_cal(G)(t_1)$) 
    
    In the end \ #par(first-line-indent: 1em, $d_(cal(G)_epsilon)(i) = w(i, r) + d_cal(G)_epsilon (r) <= (1 + epsilon)(w(i, t_1) + d_cal(G)(t_1)))$)
]

#simple-slide[
  = Problem: DAG Construction

  #v(1em)

  We still have two problems: 
  1. if we construct naively this graph we should remove edges from a $O(n^2)$ graph
  2. We should compute the weight of the graph

  #v(1em)

  _We can solve both these problems efficiently at once!_
]

#simple-slide[
  = Sliding windows
  #v(1em)

  We keep $log_(1 + epsilon)L$ sliding windows all starting at $v_i$, but ending in a different position.
  The $k$-th window find the $k$-th $epsilon$-maximal edge. 

  #figure(
    image("images/sliding-windows.svg", width: 80%),
  )
  
]

#simple-slide[
  = Sliding windows
  #v(1em)

  For each compressor we should implement 2 operations on the windows `advance_left`, `advance_right`:
  The first operation advances the start of *all* the windows.

  #figure(
    image("images/sliding-windows-advance-start.svg", width: 80%),
  )
]

#simple-slide[
  = Sliding windows
  #v(0.5em)
  `advance_right` 
  advance the end of the $k$-th window of one position.
  
  We call this function until we reach the last edge smaller than $(1 + epsilon)^k$, so until we find the $k$-th maximal edge starting from node $i$.
  #figure(
    image("images/sliding-windows-advance-end.svg", width: 70%),
  )
  if the operations `advance_left` and `advance_right` have respectively a complexity of $O(L)$ and $O(R)$ our algorithm execute asymptotically $O(n L + n log_(1+epsilon) R)$ steps
]

#simple-slide[
  = Algorithm
  #v(0.5em)
  TODO:

]

#centered-slide[
  The authors provide several implementations of the sliding windows framework to estimate the size of different compressors, among the others statistical compressors (using 0-th order and k-order entropy)
]


#focus-slide[
  = Thank You!
]

// #hidden-bibliography(
// #text(small-size)[
//   #bibliography("local.bib")
// ]
// )

