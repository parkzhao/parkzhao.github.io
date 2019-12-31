title: 『译文』Queues vs. Topics vs. Virtual Topics (in ActiveMQ)
date: 2019-12-16 22:05:31
tags: [ActiveMQ,Topic,Queues,Virtual Topics]
---
`ActiveMQ`提供了一种不同的消息模式，当队列(`queues`)和主题(`topics`)越来越流行的时候。`virtual topics`将两者很好的统一在了一起:多个消费者拥有自己的专属队列。
# Queues
![队列](http://tp.linqmind.com/2019-12-16-141044.jpg)
队列(`queues`)作为一种最常见的消息模式被`ActiveMQ`实现.在消费者与生产者之间提供了一个直接的通道。生产者创建消息，消费者一个一个的读取，读取此消息后，该消息就消失了。如果多个消费者注册了同一个队列(`queues`),只有一个会获取到该消息。
## Pros
- 简单的消息模式与一个透明的通信流。
- 可以通过把消息放回到队列中，恢复过来。

## Cons
- 只有一个消费者可以得到消息
- 意味着生产者和消费者之间的耦合,因为它是一个一对一的关系
  

# Topics
![](http://tp.linqmind.com/2019-12-16-141851.jpg)
主题(`Topics`)在一个生产者与多个消费者直接实现了一个一对多的通道。主题和队列不同，每一个消费者将会接收到生产者发送的消息。

## Pros

- 多个消费者获取同一个消息
- 生产者与消费者之间解耦(发布订阅模式)

## Cons

- 更加复杂的通信流
- 相对于单个监听器，消息不能够被恢复

# Virtual Topics
![](http://tp.linqmind.com/2019-12-16-145734.jpg)

虚拟主题(`Virtual topics`) 将上面的两种进行了合并。当生产者发送了一个消息到一个主题, 消费者将从他们自己的队列中，获取一份消息拷贝。

## Pros

- 单个消息可以被多个消费者获取。
- 生产者与消费者解耦,发布订阅模式(publish-and-subscribe pattern)
- 消息可以通过重新放回到队列中进行恢复。

## Cons

- 可能需要在节点进行额外的配置。
  
# 注意
队列和主题,都有自己的缺点。队列耦合生产者和消费者,主题缺乏一个简单的方法来恢复单个消费者的错误。虚拟主题提供一个解决方案的问题。生产者和消费者是解耦的发布-订阅模式,错误恢复可以放在单个队列。

# 原文
https://tuhrig.de/queues-vs-topics-vs-virtual-topics-in-activemq/