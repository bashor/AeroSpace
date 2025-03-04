class TilingContainer: TreeNode {
    var orientation: Orientation
    var layout: Layout
    override var parent: TreeNode { super.parent ?? errorT("TilingContainers always have parent") }

    init(parent: TreeNode, adaptiveWeight: CGFloat, _ orientation: Orientation, _ layout: Layout) {
        self.orientation = orientation
        self.layout = layout
        super.init(parent: parent, adaptiveWeight: adaptiveWeight)
    }

    static func newHList(parent: TreeNode, adaptiveWeight: CGFloat) -> TilingContainer {
        TilingContainer(parent: parent, adaptiveWeight: adaptiveWeight, .H, .List)
    }

    static func newVList(parent: TreeNode, adaptiveWeight: CGFloat) -> TilingContainer {
        TilingContainer(parent: parent, adaptiveWeight: adaptiveWeight, .V, .List)
    }
}

extension TilingContainer {
    func normalizeWeightsRecursive() {
        guard let delta = (getWeight(orientation) - children.sumOf { $0.getWeight(orientation) })
            .div(children.count) else { return }
        for child in children {
            child.setWeight(orientation, child.getWeight(orientation) + delta)
            if let tilingChild = child as? TilingContainer {
                tilingChild.normalizeWeightsRecursive()
            }
        }
    }

    func normalizeContainersRecursive() {
        if children.isEmpty && !isRootContainer {
            unbindFromParent()
        }
        if let child = children.singleOrNil() as? TilingContainer, config.autoFlattenContainers {
            let previousBinding = unbindFromParent()
            child.bindTo(parent: parent, adaptiveWeight: previousBinding.adaptiveWeight, index: previousBinding.index)
            child.normalizeContainersRecursive()
        } else {
            for child in children {
                if let tilingChild = child as? TilingContainer {
                    tilingChild.normalizeContainersRecursive()
                }
            }
        }
    }

    var isRootContainer: Bool { parent is Workspace }
}

enum Orientation {
    /// Windows are planced along the **horizontal** line
    case H
    /// Windows are planced along the **vertical** line
    case V
}

enum Layout {
    case List
    case Accordion
}
