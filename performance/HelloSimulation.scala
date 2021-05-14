package com.bee.perf

import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._

class HelloSimulation extends Simulation {

  val uuidFeeder = Iterator.continually(Map("uuid" -> java.util.UUID.randomUUID.toString()))
  
  val httpProtocol = http
    //.baseUrl("http://localhost:8080")
    //.baseUrl("http://20.74.8.160")
    .baseUrl("https://azapp-hello-app-dev.azurewebsites.net/")
    //.baseUrl("https://azapp-hello-app-dev-staging.azurewebsites.net/")

  // A scenario is a chain of requests and pauses
  val scn = scenario("Main scenario")
    .feed(uuidFeeder)
    .exec(
      http("say-hello")
        .get("?name=${uuid}")
        .check(jsonPath("$.name").is("Hello, ${uuid}!"))
    )

  // https://gatling.io/docs/current/general/simulation_setup/  
  //setUp(scn.inject(rampUsers(120).during(30.seconds)).protocols(httpProtocol))
  setUp(scn.inject(rampUsers(1200).during(600.seconds)).protocols(httpProtocol))
}
