from typing import Any

from pydantic import Field

from OperatonContracts import TaskContract, template_hints
from OperatonContracts.templates import TaskTemplate, TemplateGroup


class OrderProcessingInput(TaskContract):
    order_id: str = Field(
        alias="orderId",
        title="Order ID",
        min_length=3,
        json_schema_extra=template_hints(value="${orderId}"),
    )
    order_count: int = Field(
        alias="orderCount",
        title="Order Count",
        ge=1,
        default=1,
        strict=False,
        json_schema_extra=template_hints(type="String", value="${orderCount}"),
    )
    is_urgent: bool = Field(
        alias="isUrgent",
        title="Urgent Order",
        default=False,
        strict=False,
    )


class OrderProcessingOutput(TaskContract):
    order_result: dict[str, Any] = Field(
        alias="orderResult",
        title="Order Result",
    )


TEMPLATES = (
    TaskTemplate(
        topic="orders.process",
        template_id="org.example.orders-process",
        name="Process Order",
        description="Process customer orders with contract validation.",
        filename="orders-process.json",
        inputs=OrderProcessingInput,
        outputs=OrderProcessingOutput,
        groups=(TemplateGroup("main", "Order Processing"),),
        input_group="main",
        output_group="main",
    ),
)
