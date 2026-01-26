#import "./theme/fcb.typ": *
#import "@preview/cades:0.3.1": qr-code
#import "@preview/algorithmic:1.0.7"
#import algorithmic: style-algorithm, algorithm-figure
#show: style-algorithm
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
// #codly(zebra-fill: none)
#codly(number-format: none) // #codly(number-format: it => [#it])
#codly(languages: codly-languages)

#let background = white // silver
#let foreground = black
#let primary = rgb(56, 59, 83)
// #let link-background = rgb(255, 178, 178).darken(40%)
#let link-background = black
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

#let highlight(color, text) = {
  box(outset: (y: 8pt), fill:color, text)
}

#title-slide[
  = On Optimally Partitioning a Text to Improve Its Compression @optimalpartition

  #v(1em)

  Davide Cologni#footnote[
      RAVEN Group -- Ca' Foscari University of Venice, \
      #h(1.5em) Github: #link("https://github.com/colobrodo")[github.com/colobrodo], \
      #h(1.5em) Email: #link("mailto:davide.cologni@unive.it")[davide.cologni\@unive.it] \
    ], PhD Student

    Venice, Italy -- #datetime.today().display("[day] [month repr:long] [year repr:full]")
]


#centered-slide[
  = Problem: Text Partitioning

  #v(1em)

  #align(horizon + center)[
    We have a *compressor $scr(C)$* and a *text $T$* of size $n$, we want to *divide $T$* into $k <= n$ parts, $T[1..i_1-1]T[i_1..i_2-1]...T[i_(k-1)..n]$ and *compress each* of them individually with $scr(C)$ to improve the overall compression

    *Note:* We do *not* _permute_ the string.\ We are only interested in _partitioning_ it. 
  ]
]

#centered-slide[
  = Text Partitioning Example

  #v(1em)

  #align(horizon + center)[
    Suppose we have the text $T = "a"^n"b"^n$.

    If we compress the entire text at once we should use one bit per symbol, or *$O(n)$ bits*.
    
    If instead we partition the text to compress $"a"^n$ and $"b"^n$ separately we can compress the whole string using only *$O(log_2(n))$ bits* indicating just the length of each substring.
  ]
]

#centered-slide[
  = Reduction to SSSP
  We can model the partition problem as a *directed graph* with $n + 1$ _ordered_ vertices, where an edge exists between $v_i$ and $v_j$ only if $1 <= i < j <= n + 1$ 

  #figure(
    image("images/reduction.svg", width: 80%),
  ) <reduction>
  

]

#centered-slide[
  = Reduction to SSSP - Bijection between paths and partitions

  #v(1.5em)

  #one-by-one(start: 1)[
    In this graph each *edge* represents a *substring* of the text.

    We can then show that there exists a *bijection* from each *path* $pi = (v_1, v_i_1) ... (v_i_k, v_(n+1))$ in the graph, and a *partitioning* of the text $T$ in the form $T[1..i_1-1]T[i_1..i_2-1]...T[i_k..n]$
  ]

  #figure(
    image("images/bijection2.svg", width: 80%),
    caption: [We can map the path $pi=$ #highlight(rgb(255, 178, 178).transparentize(10%), $(v_1, v_4)$) #highlight(rgb(178, 178, 255).transparentize(30%), $(v_4, v_6)$) to the partitioning of the string #highlight(rgb(255, 178, 178).transparentize(10%), $T[1, 3]$) #highlight(rgb(178, 178, 255).transparentize(30%), $T[4, 5]$)]
  ) <bijection>

]

#centered-slide[
  = Reduction to SSSP - Bijection between paths and partitions

  #v(2em)

  #one-by-one(start: 1)[
    If we weight each edge $(i, j)$ of the graph by the cost of compressing the corresponding text segment $w(i, j) = |scr(C)(T[i, j-1])|$, we can solve the partitioning problem _optimally_ computing the *Single Source Shortest Path (SSSP)*

    It can be computed efficiently in $O(|E|)$ time using a classic dynamic programming algorithm. 
  ]

]

#focus-slide[
  *Problems:*
  #v(0.5em)
  1. Our graph has $O(n^2)$ nodes by construction
  2. To initialize the weight $w(i, j)$ we should execute $scr(C)$ on every substring of the text
]

#centered-slide[
  = Assumption on $scr(C)$

  #v(0.5em)

  - Our compressor is _monotonic_: the compressed output on a suffix or a prefix of the string is always smaller than the compression on the whole string: 
  $|scr(C)(T[i, j])| >= |scr(C)(T[i, j - 1])|$
  
  $|scr(C)(T[i, j])| >= |scr(C)(T[i + 1, j])|$
  
  - We can compute the size of the compressed output incrementally: computing $|scr(C)(T[i, j])|$ from the state of $scr(C)(T[i - 1, j])$ or $scr(C)(T[i, j - 1])$ takes constant time
]

#centered-slide[
  = How the property of monotonicity affect the topology of our DAG?
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

  Thanks to this property we can obtain an approximated algorithm by *sparsifying* the graph thus selecting only some edges.

  We are able to obtain a *$(1 + epsilon)$-approximation*, for every $epsilon >= 0$, with a time complexity of *$O(n log_(1 + epsilon) L)$* 
  
  where $L = w(1, n)$, so the cost of compressing the entire text.

  This algorithm can be applied to every dynamic programming algorithm in the form $E[j] = min_(1 <= i < j)\(E[i] + w(i, j)\)$ when $w$ is _monotone_!

]

#let idea_color = yellow.transparentize(70%)

#simple-slide[
  = #highlight(idea_color, [Key Idea: $epsilon$-maximal edges])

  #v(0.5em)

  #align(center)[*How we can select some edges to obtain the $(1 + epsilon)$ approximation factor?*]
  
  For each node $i$ select the *$epsilon$-maximal* edges, so the outgoing edge from $i$ that satisfy one of these conditions:
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

#let lemma_color = purple.transparentize(70%)

#simple-slide[
  == Our edges are increasing and can be approximated but what can we say about _paths_ in this graph?
  #align(horizon)[
    == #highlight(lemma_color, "Lemma 1")
    Let $d_scr(G)(i)$ be the cost of the shortest path $pi_i$ in our graph $scr(G)$ from $v_i$ to $v_(n+1)$ then 
    
    for all the vertices $i, j: 1 <= i < j <= n + 1$, $d_scr(G)(i) >= d_scr(G)(j)$
  ]
]

#simple-slide[
  #align(horizon)[ 
     #figure(
        image("images/lemma1.svg", width: 80%)
     )
  ]
]

#hidden-slide[
  #align(horizon)[
  *Proof by induction:*
  - Base, trivial case for $n + 1$
  - Then we need to show that $d_scr(G)(i) >= d_scr(G)(i + 1)$ by constructing a path $pi'_(i+1)$ that starts from $i + 1$ and it is always shorter than $d_scr(G)(i)$
  ]
]

#hidden-slide[
  Let #highlight(rgb(178, 178, 255).transparentize(30%), $d_scr(G)(i)$) be #highlight(rgb(178, 178, 255).transparentize(30%), $(v_i, v_t_1)(v_t_1, v_t_2)...(v_t_k, v_(n+1))$)
    1. Trivial if $t_1 = i + 1$: $pi'_(i+1) = (v_t_1, v_t_2)...(v_t_k, v_(n+1))$
    #figure(
      image("images/shortest-path-first-case.svg", width: 80%),
    ) <shortest-path>
    2. If $t_1 > i + 1$ then we can construct a shorter path  #highlight(rgb(255, 178, 178).transparentize(10%), $pi'_(i+1) = (v_(i+1), v_t_1)(v_t_1, v_t_2)...(v_t_k, v_(n+1))$) because thanks to the definition of _monotonicity_ we know that $w(i, t_1) >= w(i + 1, t_1)$ 

    #figure(
      image("images/shortest-path-colored.svg", width: 80%),
    ) <shortest-path>
]

#centered-slide[
  = Theorem
  Let $scr(G)$ be the full graph and $scr(G)_epsilon$ be the graph containing only $epsilon$-maximal edges, then $d_(scr(G)_epsilon)(i) <= (1 + epsilon)d_(scr(G))(i)$ for every integer $1 <= i <= n + 1$.
]

#simple-slide[
  *Proof by induction on $pi(i)$:*
  - *Base*, trivial case for $n + 1$ 
  - Let $pi(i) = (v_i, v_t_1) .. (v_t_h, v_n)$ the shortest path starting from node $v_i$ and let $d_scr(G)(i) = w(i, t_1) + d_scr(G)(t_1)$ be its cost.
    We choose the $epsilon$-maximal node $r$ that covers $t_1$: 
    So #highlight(lemma_color, $r > t_1$) and we already know (by our #highlight(idea_color, "\"key idea\"")) that #par(first-line-indent: 1em, highlight(idea_color, [$w(i, r) <= (1 + epsilon)w(i, t_1)$])) 
    
    By #highlight(lemma_color, [_Lemma 1_]): \ #par(first-line-indent: 1em,
      highlight(lemma_color, [$d_scr(G)(r) <= d_scr(G)(t_1) $])) 
  
    By inductive hypothesis: \ 
    #par(first-line-indent: 1em, $d_scr(G)_epsilon (r) <= (1 + epsilon)d_scr(G)(r) <= (1 + epsilon)d_scr(G)(t_1)$) 
    
    In the end \ #par(first-line-indent: 1em, $d_(scr(G)_epsilon)(i) = w(i, r) + d_scr(G)_epsilon (r) <= (1 + epsilon)(w(i, t_1) + d_scr(G)(t_1)))$)

    #figure(
      image("images/theorem.svg", width: 80%),
    ) <theorem>
]

#simple-slide[
  = Problem: DAG Construction

  #v(1em)

  We still have two problems: 
  1. if we construct _naively_ this graph we should remove edges from a $O(n^2)$ graph
  2. and we should compute the weight of each edge of the graph

  #v(1em)

  _We can solve both these problems efficiently at once:_
  We can find the $epsilon$-maximal edges efficently on the fly!
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
  The first operation advances the start of *all* the windows to the left.

  The cost of all the windows increase or stay the same.  

  #figure(
    image("images/sliding-windows-advance-start.svg", width: 80%),
  )
]

#simple-slide[
  = Sliding windows
  #v(0.5em)
  `advance_right` 
  advance the end of the $k$-th window of one position to the left.
  
  We call this function until we reach the first edge smaller than $(1 + epsilon)^k$, so until we find the $k$-th maximal edge starting from node $i$.
  #figure(
    image("images/sliding-windows-advance-end.svg", width: 70%),
  )
  if the operations `advance_left` and `advance_right` have respectively a complexity of $O(L)$ and $O(R)$ our algorithm execute asymptotically $O(L n + R n log_(1+epsilon) n)$ steps
]

#centered-slide[
   #align(horizon)[
	  The authors provide several implementations of the sliding windows framework to estimate the size of different compressors, among the others statistical compressors (using 0-th order and k-order entropy)
  ]
]

#simple-slide[
  = Computing Zero Order Entropy

  #v(1em)

  Zero-th order entropy is a well-known lower bound for the performance of statistical compressors.

  For each windows $w_k$ that covers the substring $T[i..j]$, we maintain a histogram, $A_k [c]$, indexed by the symbol $c in sum$ and the value

  #align(center)[
    $E_k = sum_(c in sum) A_k [c] log_2 A_k [c]$
  ]
]  
#simple-slide[

  Using $E_k$, we can calculate a lower bound on the output of the statistical compressor, $|scr(C)(T[i..j])|$ based on the zero-th order entropy as
  #align(center)[
    $|T[i..j]| H_0 (T[i..j]) = |T[i..j]| log_2|T[i..j]| - E_k $
  ]
]

#simple-slide[
  From this we can calculate incrementally the value of $E_(k + 1)$ removing the old term from the summation and adding the new one: 
  
  Let $c = T[j+1]$ then
  
  #align(center)[
    $E_(k+1) = E_k - A_k [c] log_2 A_k [c] + (A_k [c] + 1)(log_2 A_k [c] + 1)$
  ]
 
]

#focus-slide[
  = Thank You!
]

#text(small-size)[
  #bibliography("local.bib")
]

#simple-slide[
  = Bonus Slides: Partitioned Elias--Fano
  === Elias--Fano Data Structure
  A compact data structure to store a set of $m$ monotonically increasing integers upper-bounded by $u$. 
  
  It uses $approx ceil(log_2 u / m) + 2$ bits per element.
  
  #figure(
    image("images/ef2.svg", width: 80%),
  )

  Note that $u/m$ is the average distance between consecutive elements. It doesn't exploit the distribution of the data, but denser lists require fewer bits.
  
  Some sequence are more compressible than others
  
  #figure(
    image("images/compressible-ef2.svg", width: 80%),
  )
]



#simple-slide[
  = Partitioned Elias-Fano @OtVPEFI
  We can improve compression by exploiting clusters of data with a two-level structure. 
  The first level determines the bounds of the $b$ clusters, and the second level contains smaller Elias-Fano lists.

  #figure(
    image("images/pef.svg", width: 45%),
  )

  *How can we find the best partitioning to minimize the space occupancy of both levels?*

  We can use our partitioning algorithm, assigning a weight to each edge based on the number of bits required to represent the partition in the first level and the Elias-Fano structure in the second level.
  
  The authors also improved the bound by showing that substituting an edge in the path with two sub-edges is always bounded by a constant factor.  
]


