// Credits for the theme to Federico Bruzzone: 
// https://github.com/FedericoBruzzone/your-optimizing-compiler-is-not-optimizing-enough/tree/main/theme

#import "@preview/polylux:0.4.0": *

#let fcb-footer = state("fcb-footer", [])
#let fcb-header = state("fcb-header", [])
#let fcb-background = state("fcb-background", white)
#let fcb-foreground = state("fcb-foreground", black)
#let fcb-primary = state("fcb-primary", black)
#let fcb-link-background = state("fcb-link-background", blue)
#let fcb-header-footer-foreground = state("fcb-header-footer-foreground", gray)

#let fcb-theme(
  aspect-ratio: "16-9",
  header: [],
  footer: [],
  background: white,
  foreground: black,
  primary: black,
  link-background: blue,
  header-footer-foreground: gray,
  body
) = context {
  fcb-background.update(background)
  fcb-foreground.update(foreground)
  fcb-primary.update(primary)
  fcb-header-footer-foreground.update(header-footer-foreground)
  fcb-link-background.update(link-background)
  fcb-header.update(header)
  fcb-footer.update(footer)

  set page(
    paper: "presentation-" + aspect-ratio,
    margin: 2em,
    header: none,
    footer: none,
    fill: fcb-background.get(),
  )
  // Set default text styles
  set text(font: "Open Sans", fill: fcb-foreground.get(), size: 25pt)
  show footnote.entry: set text(size: .6em)
  show heading.where(level: 2): set block(below: 2em)

  // Set and show outline. That is, the table of contents
  set outline(target: heading.where(level: 1), title: none)
  show outline.entry: it => it.body
  show outline: it => block(inset: (x: 1em), it)

  // Emphasize numbers
  show cite: it => {
    show regex("\d"): set text(fcb-link-background.get())
    it
  }

  // Show links
  show link: this => {
    let show-type = "bold-underline"
    let label-color = foreground // A label is something like: <a> or #label("a")
    let default-color = link-background

    if show-type == "box" {
      if type(this.dest) == label {
        // Make the box bound the entire text:
        set text(bottom-edge: "bounds", top-edge: "bounds")
        box(this, stroke: label-color + 1pt)
      } else {
        set text(bottom-edge: "bounds", top-edge: "bounds")
        box(this, stroke: default-color + 1pt)
      }
    } else if show-type == "filled" {
      if type(this.dest) == label {
        text(this, fill: label-color)
      } else {
        text(this, fill: default-color)
      }
    } else if show-type == "bold-underline" {
      if type(this.dest) == label {
          let this = text(this, fill: label-color, weight: "semibold")
          underline(this, stroke: label-color)
      } else {
          let this = text(this, fill: default-color, weight: "semibold")
          underline(this, stroke: default-color)
      }
    } else if show-type == "underline" {
      if type(this.dest) == label {
          let this = text(this, fill: label-color)
          underline(this, stroke: label-color)
      } else {
          let this = text(this, fill: default-color)
          underline(this, stroke: default-color)
      }
    } else {
      this
    }
  }

  body
}

#let deco-format(it) = toolbox.full-width-block(
  fill: fcb-background.get(),
  inset: 8pt,
)[#text(size: .6em, fill: fcb-header-footer-foreground.get(), it)]

#let small-format(it) = toolbox.full-width-block(
  inset: 8pt,
)[#text(size: 18pt, it)]

#let centered-slide(body) = {
  set page(
    footer: context {
      small-format({
        stack(
          dir: ltr,
          h(1fr),
          toolbox.slide-number + " / " + toolbox.last-slide-number
        )
      })
    },
    footer-descent: 1em,
    header-ascent: 1em,
  )
  slide(align(center + horizon, body))
}

#let title-slide(body) = {
  set heading(outlined: false)
  centered-slide(body)
}

// #let focus-slide(background: aqua.darken(50%), foreground: white, body) = {
#let focus-slide(body) = context {
  set page(fill: fcb-primary.get())
  set text(fill: fcb-background.get(), size: 37pt)
  centered-slide(body)
}

#let simple-slide(body) = context {
  set page(
    footer: context {
      small-format({
        stack(
          dir: ltr,
          h(1fr),
          toolbox.slide-number + " / " + toolbox.last-slide-number
        )
      })
    },
    footer-descent: 1em,
    header-ascent: 1em,
  )
  slide(body)
}
