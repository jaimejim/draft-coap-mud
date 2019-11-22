---
title: Using MUD on CoAP environments
abbrev: MUD and CoAP
docname: draft-jimenez-mud-coap-latest
category: info

ipr: trust200902
area: IRTF
workgroup: T2TRG Research Group
keyword: CoAP, MUD, Problem Details

stand_alone: yes
pi: [toc, sortrefs, symrefs, iprnotified]

author:
 -
    ins: J. Jimenez
    name: Jaime Jimenez
    organization: Ericsson
    phone: "+358-442-992-827"
    email: jaime@iki.fi

normative:
  RFC7252:
  RFC8520:
  RFC8576:
  
informative:
  RFC6690:
  RFC7641:
  I-D.ietf-core-resource-directory:
  I-D.ietf-core-coral:
  I-D.hartke-t2trg-coral-reef:

--- abstract
This document provides some suggestions to add Manufacturing Usage Descriptions (MUD) to CoAP environments.

--- middle

# Introduction

Manufacturer Usage Description (MUD) have been specified on {{RFC8520}}. As the RFC states, the goal of MUD is to provide a means for end devices to signal to the network what sort of access and network functionality they require to properly function.

While {{RFC8520}} contemplates the use of CoAP {{RFC7252}} in the form of CoAP URLs it does not explain how MUDs can be used in a CoAP network. Moreover, in CoAP we can host the MUD file on the CoAP endpoint itself, instead of hosting it on a dedicated MUD File Server. Schemes that rely on connectivity to bootstrap the network might be flaky if that connectivity is not present. This however, may introduce new security and networking challenges.

## Requirements Language

{::boilerplate bcp14}

# MUD Architecture

MUDs are defined in {{RFC8520}} and are composed of:

- A URL that can be used to locate a description;
- The description itself, including how it is interpreted; and
- a means for local network management systems to retrieve the description
- from a MUD File Server.

Their purpose is to provide a means for end devices to signal the network what sort of access and network functionality they require to properly function.  In a MUD scenario, the end device is a "Thing" that exposes a "MUD URL" to the network. Routers or Switches in the path that speak MUD can forward the URL to "MUD Managers" that query a "MUD file server" and retrieve the "MUD File" from it. After processing, the "MUD Manager" applies an access policy to the IoT Thing.

~~~
.......................................                      +-------+
.                      ____________   .                      |  MUD  |
.                     +            +  .          +-----------+-+File |
.                     |    MUD     +-->get URL+->+    MUD      +-----+
.                     |  Manager   |  .(https)   | File Server |
.  End system network +____________+<+MUD file<-<+-------------+
.                             .       .
.                             .       .
. _______                 _________   .
.+       + (DHCP et al.) + router  +  .
.| Thing +---->MUD URL+->+   or    |  .
.+_______+               | switch  |  .
.                        +_________+  .
.......................................

~~~
{: #arch-fig title='Current MUD Architecture' artwork-align="center"}

MUDs can be used to automatically permit the device to send and receive only the traffic it requires to perform its intended function. MUDs can also be used to paliate DDOS attacks, for example by prohibiting unauthorized traffic to and from IoT devices. Even if an IoT device becomes compromised, MUD prevents it from being used in any attack that would require the device to send traffic to an unauthorized destination.

Overall a MUD is emitted as a URL using DHCP, LLDP or through 802.1X, then a Switch or Router will send the URI to some IoT Controlling Entity. That Entity will fetch the MUD file from a Server on the Internet over HTTP {{RFC8576}}.

## Problems

The biggest issue with this architecture is that if the MUD File server is not available at a given time, no Thing can actually join the network. Relying on a single server is generally not a good idea.

Another potential issue is that MUD files seem to be oriented to classes of devices and not specific device instances. It could be that during bootstrapping or provisioning different devices of the same class have different properties and thus different MUD files, more granularity would be preferable.

This brings us to the third problem, which is that the MUD file is somewhat static on a web server and out of the usual interaction patterns towards a device. In CoAP it seems that properties intrinsic to a device (e.g. sensing information) or configuration information (e.g. lwm2m objects used for management) are hosted by the device too, even if they could be replicated by a cloud server.

# MUD on CoAP

{{RFC8520}} allows a Thing to use the CoAP protocol scheme on the MUD URL. In this document we modify slightly the architecture. The components are:

- A URL using the "coaps://" scheme that can be used to locate a description;
- The description itself, including how it is interpreted, which is now hosted on the thing under the path "/.well-known/core" and
- a means for local network management systems to retrieve the mud description
- which is hosted by the Thing itself acting as CoAP MUD File Server.

~~~
...................................................
.                                  ____________   .
.                                 +            +  .
.             +-----------------> |    MUD     |  .
.   get URL   |                   |  Manager   |  .
.   (coaps)   |                   +____________+  .
.  MUD file   |                         .         .
.             |                         .         .
.             |     End system network  .         .
.             |                         .         .
.           __v____                 _________     .
.          +       + (DHCP et al.) + router  +    .
.     +--- | Thing +---->MUD URL+->+   or    |    .
.     |MUD +_______+               | switch  |    .
.     |File  |                     +_________+    .
.     +------+                                    .
...................................................
~~~
{: #arch2-fig title='Self-hosted MUD Architecture' artwork-align="center"}


## Basic Operation

The operations are similar as specified on {{RFC8520}}:

1. The device performs first DHCPv4/v6 and gets an IP address. The network can provide a temporary address before MUD validation starts.
2. The device may then emit a subsequent  DHCPREQUEST using the DHCPv4/v6 option, including the CoAP MUD URL (e.g. ```coaps://[2001:db8:3::123]/mud/light-class.senml```) indicating that it is of the class type of "light".
[how about broadcasting coaps://[localhost]/mud/light-class.senml instead here?]
3. The router (DHCP server) may implement the MUD functionality and will send the information to the MUD manager, which MAY be located on the same subnet.
4. The MUD manager will then get the MUD file from the Thing's "/mud" resource.

The use of CoAP does not change how {{RFC8520}} uses MUDs.

## CoAP Operations

Things can expose MUDs as any other resource. MUD Managers can send a GET requests to a CoAP server for "/.well-known/core" and get in return a list of hypermedia links to other resources hosted in that server. Among those, it will get the path to the MUD file, for example "/mud" and Resource Types like "rt=mud".

### Discovery

#### Resource Directory 

By using {{I-D.ietf-core-resource-directory}}, devices can register a MUD file on the Resource Directory and use it as a MUD repository too. Making it discoverable with the usual RD Lookup steps.

Lookup will use the resource type "rt=mud", the example in Link-Format {{RFC6690}} is:

~~~
REQ: GET coap://rd.company.com/rd-lookup/res?rt=mud

RES: 2.05 Content

     <coap://[2001:db8:3::101]/box>;rt="mud";
       anchor="coap://[2001:db8:3::101]"
     <coap://[2001:db8:3::102]/switch>;rt="mud";
       anchor="coap://[2001:db8:3::102]",
     <coap://[2001:db8:3::102]/lock>;rt="mud";
       anchor="coap://[2001:db8:3::102]",
     <coap://[2001:db8:3::104]/light>;rt="mud";
       anchor="coap://[2001:db8:3::104]"
~~~

The same example in CoRAL ({{I-D.ietf-core-coral}}, {{I-D.hartke-t2trg-coral-reef}}) is:

~~~
REQ: GET coap://rd.company.com/rd-lookup/res?rt=mud
     Accept: TBD123456 (application/coral+cbor@identity)

RES: 2.05 Content
     Content-Format: TBD123456 (application/coral+cbor@identity)
     
     rd-item <coap://[2001:db8:3::101]/box> { rt "mud" }
     rd-item <coap://[2001:db8:3::102]/switch> { rt "mud" }
     rd-item <coap://[2001:db8:3::102]/lock> { rt "mud" }
     rd-item <coap://[2001:db8:3::103]/light> { rt "mud" }
~~~

#### Multicast

{{RFC7252}} registers one IPv4 and one IPv6 address each for the purpose of CoAP multicast. All CoAP Nodes can be addressed at "224.0.1.187" and at "FF0X::FD". Multicast could also be used to discover all Manufacturer descriptions in a subnet.

The example in Link-Format {{RFC6690}} is:

~~~
GET coap://[FF0X::FE]/.well-known/core?rt=mud
~~~

The same example in in CoRAL ({{I-D.ietf-core-coral}}, {{I-D.hartke-t2trg-coral-reef}}) is:

~~~
REQ: GET coap://[FF0X::FE]/.well-known/core?rt=mud
     Accept: TBD123456 (application/coral+cbor@identity)
~~~

#### Direct MUD discovery

Using {{RFC6690}} using CoRE Link Format, a CoAP endpoint could attempt to configure itself based on another Thing's MUD. For that reason it might fetch directly the MUD file from the device. It would start by finding if the endpoint has a MUD. The example in Link-Format {{RFC6690}} is:

~~~
REQ: GET coap://[2001:db8:3::123]:5683/.well-known/core?rt=mud

RES: 2.05 Content

     </mud/lightmud>;rt="mud"
~~~

In CoRAL ({{I-D.ietf-core-coral}}, {{I-D.hartke-t2trg-coral-reef}}):

~~~
REQ: GET coap://[2001:db8:3::123]:5683/.well-known/core?rt=mud
     Accept: TBD123456 (application/coral+cbor@identity)
     
RES: 2.05 Content
     Content-Format: TBD123456 (application/coral+cbor@identity)
     
     rd-item </mud/lightmud.mud> { rt "mud" }
~~~

Once the client knows that there is a MUD file under "/mud/lightmud", it can decide to follow the presented links and query it.

~~~
REQ: GET coap://[2001:db8:3::123]:5683/mud/lightmud
RES: 2.05 Content

     [{MUD Payload in SENML}]
~~~

In CoRAL ({{I-D.ietf-core-coral}}, {{I-D.hartke-t2trg-coral-reef}}):

~~~
REQ: GET coap://[2001:db8:3::123]:5683/mud/lightmud

RES: 2.05 Content

     [{MUD Payload in SENML}]
~~~

The device may also observe the MUD resource using {{RFC7641}}, directly subscribing to future network configuration changes.

# MUD File

TBD behaviors that are specific of CoAP should be here.

## Serialization

TBD write about SenML/CBOR MUDs.

# Security Considerations

Things will expose a MUD file that MUST be signed both by the MUD author and by the device operator. Security Considerations present on Section 4.1 of {{RFC8576}}.

TBD:
We might want to use BRSKI or another similar mechanism.
Optionally the device could advertise localhost on the URL with the path to the MUD. When the network has the IP it'd append the path to it in order to fetch the MUD.

# IANA Considerations

None

--- back

# Acknowledgments
{: numbered="no"}

Thanks to Klaus Hartke for the CoRAL examples and discussions as well as Michael Richardson for discussions on the problem space.