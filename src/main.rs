#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use std::net::{UdpSocket, ToSocketAddrs};
use std::io::Error;
use std::env;
use rocket::http::Status;
use rocket::config::{Config, Environment, ConfigError};

#[post("/awake")]
fn awake_nas() -> Result<&'static str, Status> {
    send_wol(
        vec![0x00, 0x11, 0x32, 0x2c, 0x68, 0x6d],
        "255.255.255.255:9",
        "0.0.0.0:0"
    ).map_err(|_| Status::InternalServerError)?; // TODO do something with the error
    Ok("Nas awakened!")
}

fn main() -> Result<(), ConfigError>{

  if let Some(arg) = env.args().collect().head() {
    arg.
  }

  // By default `rocket::ignite()` will run in the development mode which binds
  // the server on localhost:8000.
  // One way to change the bind address is to use the ROCKET_ADDRESS env var:
  // $ ROCKET_ADDRESS=0.0.0.0 ./hello-world 
  
  let config = Config::build(Environment::Production)
    .address("0.0.0.0")
    .port(8000)
    .finalize()?;

  rocket::custom(config)
    .mount("/nas", routes![awake_nas])
    .launch();

  Ok(())
}

/**
 send(
  vec![0x01, 0x20, 0x44, 0x40, 0xf2, 0xff], // The MAC address you're targeting
  "255.255.255.255:9", // The UDP broadcast address
  "0.0.0.0:0" // The address to listen on
);
*/
pub fn send_wol<A: ToSocketAddrs>(mac: Vec<u8>, bcast_addr: A, bind_addr: A) -> Result<(), Error> {
  let mut packet = vec![0u8; 102];

  // The header is 6 0xFFs
  for i in 0..6 {
    packet[i] = 0xFF;
  }

  // We copy the mac address 16 times.
  for i in 0..16 {
    for j in 0..6 {
      packet[6 + (i * 6) + j] = mac[j];
    }
  }

  let socket = UdpSocket::bind(bind_addr)?;
  socket.set_broadcast(true)?;
  socket.send_to(&packet, bcast_addr)?;

  Ok(())
}