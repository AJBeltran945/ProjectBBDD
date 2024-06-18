# **Automated Order Processing System for Basketball Team Store**

## **Project Overview**

This project automates the order processing and inventory management for a European basketball team's online store. It addresses issues with order management, inventory tracking, and fulfillment, reducing errors and improving efficiency.

## **Features**

1. **Order Creation**
   - Automatically copies shipping address fields from `Client` to `Order` during order creation.

2. **Order Total Calculation**
   - Recalculates the total amount of an `Order` when `OrderLineItems` are added or removed.

3. **Unit Price Setting**
   - Sets the product's price in the “Unit Price” field when an `OrderLineItem` is inserted or modified.

4. **WorkOrder Management**
   - Creates a `WorkOrder` when an order transitions to “Accepted” status.
   - Generates `WorkOrderItems` based on `OrderLineItems`.

5. **Shipment Management**
   - Creates a `Shipment` when a `WorkOrder` is completed.
   - Generates `ShipmentItems` based on `WorkOrderItems`.

6. **Order Status Updates**
   - Updates the order's status to “Sent” when a `Shipment` is created.
   - Updates the order's status to “Completed” when all related shipments are delivered.

7. **Price Update Propagation**
   - Updates `OrderLineItems` prices when a product’s price changes, given the order is in “Draft” status.

