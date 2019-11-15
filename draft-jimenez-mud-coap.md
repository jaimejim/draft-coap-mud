---
title: Using MUD files in CoAP
abbrev: draft-jimenez-mud-coap
docname: draft-jimenez-mud-coap
date: 2019-10-10
category: info

ipr: trust200902
area: CoRE

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

informative:
  RFC7252:
  I-D.ietf-core-resource-directory:
  I-D.irtf-t2trg-iot-seccons-12:



--- abstract
This document provides a usage of the Manufacturing Usage Descriptions (MUD) on CoAP environments. 


--- middle

Introduction
============

Manufacturer Usage Description (MUD) have been specified on {{RFC8520}}. As the RFC states, the goal of MUD is to provide a means for end devices to signal to the network what sort of access and network functionality they require to properly function.

While {{RFC8520}} contemplates the use of CoAP {{RFC7252}} URLs it does not explain how MUDs can be used in a CoAP network. Moreover, in CoAP it could be more interesting to actually host the MUD file on the CoAP endpoint itself, instead of hosting it on a dedicated MUD files server. This introduces new security and networking challenges.

MUD Architecture
================

MUDs are defined in {{RFC8520}} they are composed of:

* A URL that can be used to locate a description;
* The description itself, including how it is interpreted; and
* A means for local network management systems to retrieve the description.

Their purpose is to provide a means for end devices to signal to the network what sort of access and network functionality they require to properly function.  In a MUD scenario, the "IoT Thing" exposes a "MUD URL" to the network. A "MUD Processor" queries a "MUD file server" and retrieves the "MUD File" from it. After processing the "MUD processor" applies an "Access Policy" to the IoT Thing.

~~~
.......................................
.                      ____________   .           _____________
.                     |            |  .          |             |
.                     |    MUD     |-->get URL-->|    MUD      |
.                     |  Manager   |  .(https)   | File Server |
.  End system network |____________|<-MUD file<-<|_____________|
.                             .       .
.                             .       .
. _______                 _________   .
.|       | (DHCP et al.) | router  |  .
.| Thing |---->MUD URL-->|   or    |  .
.|_______|               | switch  |  .
.                        |_________|  .
.......................................
~~~
{: #arch-fig title='Current MUD Architecture' artwork-align="center"}

MUD can be used to automatically permit the device to send and receive only the traffic it requires to perform its intended function. MUDs can also be used to paliate DDOS attacks, for example by prohibiting unauthorized traffic to and from IoT devices. Even if an IoT device becomes compromised, MUD prevents it from being used in any attack that would require the device to send traffic to an unauthorized destination.

Overall a MUD is emitted as a URL using DHCP, LLDP or through 802.1X, then a Switch or Router will send the URI to some IoT Controlling Entity. That Entity will fetch the MUD file from a Server on the Internet over HTTP {{I-D.irtf-t2trg-iot-seccons-12}}.

MUD on CoAP
===========

{{RFC7252}} does not prevent the Thing from using CoAP on the MUD URL. In this document we change slightly the architecture. The components are:

* A URL (using CoAP) that can be used to locate a description;
* The description itself, including how it is interpreted, which is now hosted on the thing under "/mud"; and
* A means for local network management systems to retrieve the description from /mud. 

~~~
...................................................
.                                  ____________   .
.                                 +            +  .
.           +-------------------> |    MUD     |  .
.   get URL |                     |  Manager   |  .
.   (coaps) |                     +____________+  .
.  MUD file |                           .         .
.           |                           .         .
.           |      End system network   .         .
.           |                           .         .
.           v______                 _________     .
.          +       + (DHCP et al.) + router  +    .
.     +--- | Thing +---->MUD URL+->+   or    |    .
.     |MUD +_______+               | switch  |    .
.     |File  |                     +_________+    .
.     +------+ /mud                               .
...................................................
~~~
{: #arch-fig title='Self-hosted MUD Architecture' artwork-align="center"}

The assumption is that a Thing will host the MUD file, without the need for a dedicated MUD File Server.

**Basic Operation**

The operations are similar as specified on {{RFC7252}}:

1. The device first emits a DHCPv4/v6 option, including the CoAP MUD URL (e.g. coap://[2001:db8:3::123]/mud/light-class) indicating that it is of the class type of "light".
2. The router (DHCP server) may implement the MUD functionality and will send the information to the MUD manager, which MAY be located on the same subnet.
3. The MUD manager will then get the MUD file from the Thing "/mud" resource.

The use of CoAP does not change how {{RFC7252}} uses MUDs.

**Web-like Operation**

Since the Things are now using CoRE Link Format, they can also expose MUDs as any other resource. MUD Managers can send a GET request to a CoAP server for /.well-known/core and get in return a list of hypermedia links to other resources hosted in that server. Among those, it will get the path to the MUD file, for example "/mud" and Resource Types like "rt=mud".

By using {I-D.ietf-core-resource-directory}}, devices can register a MUD file on the Resource Directory and use it as a MUD repository too (!). Making it discoverable with the usual RD Lookup steps. For example:
~~~~~~~~~~~~~~
REQ: POST coap://rd.device.is/rd?ep=node1
     ct:40
     </mud>;ct=41;rt="mud"
     </sensors/light>;ct=41;rt="light-lux";if="sensor"
~~~~~~~~~~~~~~

Lookup will use the resource type rt=mud, for example:

~~~~~~~~~~~~~~
REQ: GET coap://rd.jaime.win/rd-lookup/res?rt=mud
~~~~~~~~~~~~~~

The RD will return a list of links that host the mud resource.

~~~~~~~~~~~~~~
RES: 2.05 Content
     <coap://[2001:db8:3::123]:61616/box>;rt="mud";
       anchor="coap://[2001:db8:3::123]:61616"
     <coap://[2001:db8:3::124]/switch>;rt="mud";
       anchor="coap://[2001:db8:3::124]",
     <coap://[2001:db8:3::124]/lock>;rt="mud";
       anchor="coap://[2001:db8:3::124]",
     <coap://[2001:db8:3::124]/light>;rt="mud";
       anchor="coap://[2001:db8:3::124]"
~~~~~~~~~~~~~~

Multicast could also be used to discover all Manufacturer descriptions in a subnet. For example:

Security Considerations
=======================

TBD.