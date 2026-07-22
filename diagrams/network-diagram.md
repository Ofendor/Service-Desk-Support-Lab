# Network Topology – Service Desk Support Lab

Canonical network diagram for the lab environment. This is the single source of truth referenced by the README and docs. All virtual machines run in Oracle VirtualBox on one NAT Network (`ServicedeskLab`, `192.168.10.0/24`).

```mermaid
graph TD
    HOST[VirtualBox Host<br>Oracle VirtualBox]
    NET{{ServicedeskLab NAT Network<br>192.168.10.0/24<br>Gateway 192.168.10.1}}

    HOST --- NET

    NET --- DC01[AKL-DC01<br>Windows Server 2022<br>192.168.10.10 — Static<br>AD DS · DNS · DHCP · WSUS<br>Domain: servicedesk.lab]
    NET --- W11[WIN11-01<br>Windows 11 Enterprise<br>DHCP lease .100–.200<br>Domain-joined client<br>Workstations OU]
    NET --- DEB[Debian VM<br>Debian Linux<br>192.168.10.20 — DHCP Reservation<br>osTicket · Docker · MariaDB<br>Port 8081]

    DC01 -. DNS + DHCP + WSUS .-> W11
    DC01 -. DNS + DHCP .-> DEB
    W11 -. HTTP :8081 → support.servicedesk.lab .-> DEB
```

## Notes

- **Subnet / gateway:** all VMs sit on `192.168.10.0/24` behind gateway `192.168.10.1`, sharing the single VirtualBox NAT Network `ServicedeskLab`.
- **Addressing:** `AKL-DC01` is **static** at `.10`; the Debian VM is a **DHCP reservation** pinned to `.20` (below the client pool); `WIN11-01` takes a **dynamic DHCP lease** from the `.100–.200` range, so its address can change on reboot and is not a stable identifier.
- **Core services:** `AKL-DC01` provides DNS, DHCP, and WSUS to the network; `support.servicedesk.lab` resolves to the Debian VM, which hosts the osTicket ticketing system on port `8081`.