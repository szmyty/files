# Design Doc Template

[Background](#background)  
[Design Goals](#design-goals)  
[Other Proposals](#other-proposals)  
[Option 1](#option-1)  
[Option 2](#option-2)  
[Solution Summary](#solution-summary)  
[Solution Details](#solution-details)  
[System diagram](#system-diagram)  
[Wire frames](#wire-frames)  
[Code](#code)  
[Testing](#testing)  
[Scaling](#scaling)  
[Operation details](#operation-details)  
[Internationalization](#internationalization)  
[Tradeoffs made](#tradeoffs-made)

# Background {#background}

Background on the problem we’re solving.

# Design Goals {#design-goals}

Requirements and goals of the project. This should also include numbers like traffic assumptions, usage, uptime requirements, etc.

# Other Proposals {#other-proposals}

Options that were looked at, but we evaluated that weren’t going to work

## Option 1 {#option-1}

## Option 2 {#option-2}

# Solution Summary {#solution-summary}

Summary of the solution in a paragraph or two.

#

# Solution Details {#solution-details}

Details of the solution...feel free to add/remove sections that make sense, some starter ones are below.

## System diagram {#system-diagram}

Diagram of all the binaries, databases and 3rd party services that this system touches

##

## Wire frames {#wire-frames}

Any wireframes for the UI if this has a frontend component?

## Code {#code}

Where is the code going to go?  Does this touch any common repos?  Any new repos being created?

## Testing {#testing}

What kind of testing is going to be done.  Unit tests, regression tests, etc.

##

## Scaling {#scaling}

What aspects of traffic do we need to think about for scaling. If the traffic goes 10x, we ok?  could the database grow 10x and cause issues?

## Operation details {#operation-details}

Details that the operations team might want to know like location of binaries, monitoring to be setup, oncall, etc

## Internationalization {#internationalization}

Do we need to think about spanish?

## Tradeoffs made {#tradeoffs-made}

Write out the big tradeoffs made  
