function overlappingBoundingBox(aPos, a, bPos, b)
  return aPos.x + a.left_top.x <= bPos.x + b.right_bottom.x and aPos.x + a.right_bottom.x >= bPos.x + b.left_top.x and
          aPos.y + a.left_top.y <= bPos.y + b.right_bottom.y and aPos.y + a.right_bottom.y >= bPos.y + b.left_top.y
end