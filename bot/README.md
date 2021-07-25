docker run --rm -it -p 4566:4566 -p 4571:4571 localstack/localstack -e "SERVICES=dynamodb,s3"

uses the serverless-ruby-layer plugin:

    rubyLayer:
      use_docker: true
      docker_yums:
        - postgresql-devel
      native_libs:
        - /usr/lib64/libpq.so.5

Note we don't need this in pur app as we are using aws-sdk-rdsdataservice and the data api for postgres datab ase access.




# Gerty

![gerty](gerty.png)

## Here to keep you safe

Gerty is a Slackbot built on a serverless, event-driven, micro-service architecture. Gerty is built to help keep developers safe but in this repo she helps hard-working developers choose great recipes that they can make for dinner.

## Frustrating but extremely rewarding

I've been a developer for nearly twenty years now - mostly web development. Building Gerty has been the most frustrating and the most rewarding experience. Frustrating because event-driven microservices turned everything I know about building software on its head and challenged my thinking in ways that I haven't been challenged for a long time. Rewarding because I realised my long-held dream of building an application from micro services and it felt great - like creating a living thing rather than the more usual assembly of web components into an MVC framework.   

## Why Serverless, Event Driven Micro-services ?

**Serverless**: Bots are used sporadically so there's really no point:

* paying for servers running 24/7.
* paying for people to manage those servers.
* paying for complex scaling mechanisms to handle the peeks and troughs like Kubernetes.

**Event Driven**: I can think of a million uses for my bot so I want it to be able to add functionality easily. Components in event driven applications are highly decoupled making them super easy to add and remove functionality without having to touch any other running service.

**Micro-Services:** I want Gerty to be master of all trades but I also like clean code. Gerty is a "community" of small, independent services listening-for and emitting events into her architecture.

## Why you should understand the benefits of event-driven design.

### One Row to Rule Them all.... 

Imagine an online e-commerce site. Typically this would be a web-based application driven by a single database. There would be a 'products' and data from that table would be serve:

1. The web page that show that product 
2. Listing pages that included that product.
3. Data for elastic search
4. Data for a catalog export
5. Data for orders
6. Date for inventory management
7. Admin pages for editing information and imagery about the product.

One record rules 7 different contexts and binds them tightly together. A search engine's idea of a product is probably very different from an order's idea of a product yet in our model they are forced to view them the same way. We like to think we have a nice elegant 'Product' model but the reality is our class is really more like a SearchOrderInventoryAdminCatalogProduct.   

Typically we mitigate the chances of change to any one context breaking others by writing tests but we still have to consider the impact on other contexts when designing changes to any one. The complications that arise from the inevitable comprimise this dictates are where technical debt starts to creep in. 

These context also share the same resources so should one context come under intensive load we'll have to provide enoiugh resources to scale all our contexts. I onced worked on a web application where, seasonally, we had to scale our usual 6 servers to 60 for a few weeks due to the number of visitors viewing the product page. It always struck me as wrong that our admin, inventory and catalog systems also had to grow by a factor of 10 as they were all built into the same web application.

### The Microservice Rabbit Hole  

Like many developers I'd always imagined that microservices would solve all my monolithic headaches and provide me with something smarter than the ageing spaghetti code that all too often ruined my days. All I need do was slice the application into logical pieces, build a microservice for each piece then spend my days basking in the glory of engineering excellence.

Sadly it didn't even begin to work that way. For a start it's surprisingly hard to identify subdomains that are truly distinct and have no overlap with any others. Take our relatively obvious example above - seven distinct contexts yet they all heavily overlap Product. I tried to solve this by creating a Product service for the others to consume but after a lot of work this service became a complex API that was little more than a clumsy HTTP proxy for the underlying products database. We could have given all these services direct access to the products database but that isn't much different to where we started.

Each service depended on HTTP calls to other services so in reality the application was no less coupled than our monolith but with the added complexity of monitoring, deploying and dealing with failure across a system that now compirised of many moving parts. 

By now we'd written a lot of code but things felt no simpler and we'd discovered new complexities we hadn't understood at the start of our journey.

### Decoupling Code and Data

## Handlers

## Services

## Topics & Events







