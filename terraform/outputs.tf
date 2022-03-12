output "vm_id" {
    value= azurem_linux_virtual_machine.linux_virtual_machine.id
}

output "vm_ip" {
    value = azurem_linux_virtual_machine.linux_virtual_machine.public_ip_address
}