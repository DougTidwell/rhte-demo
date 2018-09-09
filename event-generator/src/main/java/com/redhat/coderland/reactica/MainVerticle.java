package com.redhat.coderland.reactica;

import io.reactivex.Completable;
import io.vertx.core.DeploymentOptions;
import io.vertx.core.Future;
import io.vertx.core.json.JsonObject;
import io.vertx.reactivex.CompletableHelper;
import io.vertx.reactivex.core.AbstractVerticle;
import me.escoffier.reactive.amqp.AmqpConfiguration;
import me.escoffier.reactive.amqp.AmqpVerticle;
import me.escoffier.reactive.amqp.EventBusToAmqp;

public class MainVerticle extends AbstractVerticle {


  @Override
  public void start(Future<Void> done) {

    deployAMQPVerticle()
      .andThen(vertx.rxDeployVerticle(BusinessEventTransformer.class.getName()).ignoreElement())
      .andThen(vertx.rxDeployVerticle(UserSimulatorVerticle.class.getName()).ignoreElement())
      .andThen(vertx.rxDeployVerticle(RideSimulator.class.getName()).ignoreElement())
      .subscribe(CompletableHelper.toObserver(done));

  }

  private Completable deployAMQPVerticle() {
    EventBusToAmqp user_queue = new EventBusToAmqp();
    user_queue.setAddress("to-user-queue");
    user_queue.setQueue("USER_QUEUE");

    // Consume by the billboard
    EventBusToAmqp enter_queue = new EventBusToAmqp();
    enter_queue.setAddress("to-enter-event-queue");
    enter_queue.setQueue("ENTER_EVENT_QUEUE");

    EventBusToAmqp ride_event_queue = new EventBusToAmqp();
    ride_event_queue.setAddress("to-ride-event-queue");
    ride_event_queue.setQueue("RIDE_EVENT_QUEUE");

    AmqpConfiguration configuration = new AmqpConfiguration()
      .setContainer("amqp-examples")
      .setHost("eventstream-amq-amqp")
      .setPort(5672)
      .setUser("user")
      .setPassword("user123")
      .addEventBusToAmqp(enter_queue)
      .addEventBusToAmqp(user_queue)
      .addEventBusToAmqp(ride_event_queue);

    return vertx.rxDeployVerticle(AmqpVerticle.class.getName(), new DeploymentOptions().setConfig(JsonObject.mapFrom(configuration))).ignoreElement();
  }
}
