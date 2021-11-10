package main

import (
	"os"
	"time"

	"github.com/mykilio/mykilio.go/pkg/broker"
	"github.com/mykilio/mykilio.go/pkg/service"
)

var (
	name    = "unknown"
	version = "dev"
)

func main() {
	// Create new service instance.
	svc := service.New(service.Config{
		Name:    name,
		Version: version,
	})

	// Configure broker connection.
	svc.UseBroker(broker.NewNATS(&broker.NATSOptions{
		URI:            os.Getenv("BROKER_URI"),
		RequestTimeout: 1 * time.Second,
	}))

	svc.BrokerChannel("channels.create", ChannelsCreate)
	svc.BrokerChannel("channels.find", ChannelsFind)
	svc.BrokerChannel("channels.delete", ChannelsDelete)

	// Wait until error occurs or signal is received.
	svc.Start()
}
