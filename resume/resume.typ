// Resume - Fachry Dennis Heraldi
// Typst format - auto-compiled via GitHub Actions

#set document(
  title: "Fachry Dennis Heraldi - Resume",
  author: "Fachry Dennis Heraldi",
)

#set page(
  paper: "a4",
  margin: (x: 0.5in, y: 0.5in),
)

#set text(
  font: "Arial",
  size: 10pt,
)

#set par(
  justify: true,
  leading: 0.5em,
)

// Disable hyphenation for ATS compatibility
#set text(hyphenate: false)

// Colors
#let primary = rgb("#2563eb")
#let muted = rgb("#64748b")

// Custom functions
#let section-title(title) = {
  v(0.3em)
  text(weight: "bold", title)
  v(-0.8em)
  line(length: 100%, stroke: 0.6pt)
  v(0.2em)
}

#let entry-header(title, location) = {
  grid(
    columns: (1fr, auto),
    text(weight: "bold", title),
    text(location),
  )
}

#let entry-subheader(role, period) = {
  grid(
    columns: (1fr, auto),
    text(style: "italic", role),
    text(style: "italic", period),
  )
}

#let bullet-item(content) = {
  grid(
    columns: (1em, 1fr),
    gutter: 0.3em,
    align(center + horizon, text(size: 0.6em, "•")),
    content,
  )
}

// Header
#grid(
  columns: (60%, 40%),
  gutter: 1em,
  [
    #text(size: 18pt, weight: "bold")[Fachry Dennis Heraldi]
    
    #text(size: 9pt)[Software engineer experienced in integrating diverse microservices into unified solutions. Adaptive to new tech, focused on building reliable, failure-tolerant systems, and dedicated to clear documentation and knowledge sharing]
  ],
  align(right)[
    #text(size: 9pt)[
      Jakarta, Indonesia | +62 882 1185 4646 \
      #link("mailto:fd.heraldi@gmail.com")[fd.heraldi\@gmail.com] \
      #link("https://linkedin.com/in/dennisheraldi")[linkedin.com/in/dennisheraldi] \
      #link("https://github.com/dennisheraldi")[github.com/dennisheraldi]
    ]
  ],
)

#v(0.5em)

// Work Experience
#section-title("Work Experience")

#entry-header("CSG International", "Jakarta")
#entry-subheader("Software Developer Engineer I", "January 2025 – Present")
#text(size: 9pt, fill: muted)[CSG is a global provider of customer experience, billing, and payment solutions for the telecom industry.]
#v(0.2em)

#bullet-item[*Contributed to development that earned company TMForum DTW 2025 award* by architecting innovative engine for *intent-driven network API transformations* as MVP of Catalyst project in *collaboration with Ericsson*, demonstrating cutting-edge telecom automation capabilities.]

#bullet-item[*Achieved zero transaction failures* by implementing comprehensive end-to-end recovery mechanism with *idempotency features, process engine auto-retry, and enhanced internal error handling*, ensuring *100% transaction reliability and recovery* for critical business operations.]

#bullet-item[*Delivered ready-to-go product solutions* by improving *50 customized XML product specifications*, refining core business processes, and modernizing Java microservices, *enhancing client configuration efficiency*.]

#v(0.5em)

#entry-header("Paper.id", "Jakarta")
#entry-subheader("Software Engineer", "November 2023 – December 2024")
#text(size: 9pt, fill: muted)[Paper.id is a platform providing invoicing, payment, and financing solutions for businesses.]
#v(0.2em)

#bullet-item[*Accelerated message template creation from hours to under a minute* by integrating third-party SMS and WhatsApp broadcast messaging services with *concurrent Goroutines processing*, enabling scalable communication capabilities for business operations.]

#bullet-item[*Architected unified payment engine* by developing generalized solution that handles *diverse bank behaviors and merchant-specific requirements*, enabling seamless multi-party integrations while *maintaining system consistency across multiple financial partnerships*.]

#bullet-item[*Achieved 99% transaction success rate* by implementing functionality for QRIS payment, direct transfers, virtual accounts, and cross-border remittances compliant with *Indonesia's Central Bank standards*, contributing to Total Payment Volume (TPV) by *4 billion IDR* in a month.]

#bullet-item[*Enhanced system robustness* by implementing *dynamic table partitioning and automated transaction reconciliation* with RabbitMQ scheduling and asynchronous transaction callbacks, *increasing query performance by 20%* and *enable instant execution of reconciliation report generation*.]

#v(0.5em)

#entry-header("Suitmedia", "Bandung")
#entry-subheader("Software Engineer Intern", "May 2023 – September 2023")
#text(size: 9pt, fill: muted)[Suitmedia is a digital agency specializing in technology and marketing, providing solutions and strategic partnerships.]
#v(0.2em)

#bullet-item[*Delivered comprehensive CMS solution* by designing and implementing *35 dynamic menus and 50 API endpoints* using Laravel framework with efficient database schemas inferred from Figma prototypes, *ensuring seamless front-end integration* and enhanced website functionality for client requirements.]

#bullet-item[*Optimized system performance and content delivery* by redesigning database structures and implementing dynamic content management with static page integration, *resulting in improved query performance by 30%* and enhanced client usability across both dynamic and static website pages.]

#v(0.5em)

#entry-header("Synpulse", "Jakarta")
#entry-subheader("Software Engineer Intern", "October 2022 – December 2022")
#text(size: 9pt, fill: muted)[Synpulse is a management consulting firm serving financial services providers.]
#v(0.2em)

#bullet-item[*Streamlined core banking system migration* by authoring functional requirements for *20 system specifications*, mapping existing to new API specifications and building system flowcharts that kept *Banking Client's Avaloq transition project on schedule*.]

#bullet-item[*Eliminated manual daily data processing* by developing automated shell scripts for Excel-to-Oracle database conversion, *reducing reconciliation report processing from 15 minutes to instant execution* and ensuring seamless core banking system migration for *Banking Client*.]

// Education
#section-title("Education")

#entry-header("Institut Teknologi Bandung", "August 2020 – October 2024")
#entry-subheader("Bachelor of Engineering – BE, Informatics", "CGPA: 3.76/4.00 (Cumlaude)")
#v(0.2em)

#bullet-item[*Relevant Coursework*: Algorithm and Data Structure, Software Project Management, Database Management, Platform-based Application Development, Parallel and Distributed Systems, Advanced Machine Learning]

// Technical Skills
#section-title("Technical Skills")

#bullet-item[*Programming Languages*: Java, Golang, PHP, Python, JavaScript, Shell Scripting]
#bullet-item[*Frameworks & Libraries*: Laravel, React, ViteJS, NodeJS, Fastify, JAX-WS]
#bullet-item[*Databases*: PostgreSQL, MySQL, ArangoDB, Oracle Database]
#bullet-item[*Tools & Platforms*: RabbitMQ, Kafka, OpenTelemetry, Vault, Consul, Retrofit, Figma]
#bullet-item[*Cloud & DevOps*: Google Cloud Platform, AWS, Docker, Jenkins]

