import pyuvm


from pyuvm import uvm_test
from cocotb import top as tb
from cocotb.triggers import ClockCycles, FallingEdge as ClockEdge
from cocotb.types import LogicArray

logger = pyuvm.logging.getLogger(__name__)
logger.setLevel(pyuvm.logging.DEBUG)


def bus_init():
    tb.bus.en.value = 0
    tb.bus.wr.value = 0
    tb.bus.rd.value = 0
    tb.bus.addr.value = 0
    tb.bus.wdata.value = 0

async def write(id, addr, data):
    tb.bus.en[id].value = 1
    tb.bus.wr.value = 1
    tb.bus.addr.value = addr
    tb.bus.wdata.value = data
    await ClockEdge(tb.clk)
    bus_init()

async def read(id, addr) -> LogicArray:
    tb.bus.en[id].value = 1
    tb.bus.rd.value = 1
    tb.bus.addr.value = addr
    await ClockEdge(tb.clk)
    bus_init()
    return tb.bus.m_rdata.value



@pyuvm.test()
class testA(uvm_test):
    async def run_phase(self):
        await super().run_phase()
        self.raise_objection()
        bus_init()
        await ClockCycles(tb.clk, 2, rising=False)
        tb.rst.value = 0
        await ClockCycles(tb.clk, 2, rising=False)
        await write(0, 1, 121)
        await ClockCycles(tb.clk, 2, rising=False)
        await write(1, 3, 42)
        await ClockCycles(tb.clk, 2, rising=False)
        assert await read(1, 3) == 42
        await ClockCycles(tb.clk, 2, rising=False)
        assert await read(0, 1) == 121
        await ClockCycles(tb.clk, 2, rising=False)


        self.drop_objection()
