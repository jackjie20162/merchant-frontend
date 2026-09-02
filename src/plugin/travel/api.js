import { listTravelProducts, getTravelProduct, checkTravelInventory, createTravelOrder, getTravelOrder } from '../../api/travel'

export const travelProductList = listTravelProducts
export const travelProductDetail = getTravelProduct
export const travelInventoryCheck = checkTravelInventory
export const travelOrderCreate = createTravelOrder
export const travelOrderDetail = getTravelOrder
